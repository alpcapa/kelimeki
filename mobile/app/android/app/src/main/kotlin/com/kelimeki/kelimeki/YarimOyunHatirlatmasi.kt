package com.kelimeki.kelimeki

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

/**
 * Yarım kalan oyun hatırlatması — telefonun KENDİSİNE kurulan tek yerel
 * bildirim (1 Ekim 2026). Dart ucu: `data/unfinished_game_reminder.dart`;
 * karar (ne zaman, hangi oyun) tamamen orada, burası yalnızca "şu anda
 * göster" ve "iptal et".
 *
 * NEDEN `setAndAllowWhileIdle` (tam zamanlı DEĞİL): Android 12+'ta tam
 * zamanlı alarm `SCHEDULE_EXACT_ALARM` izni ve Play'de ayrıca beyan
 * istiyor. Akşam hatırlatmasının birkaç dakika kayması önemsiz.
 *
 * BİLİNÇLİ SINIR: cihaz yeniden başlarsa alarm SİLİNİR. Geri kurmak
 * `RECEIVE_BOOT_COMPLETED` izni + ikinci bir alıcı isterdi; tek seferlik
 * bir hatırlatma için değmez.
 */
object YarimOyunHatirlatmasi {
    private const val ISTEK_KODU = 7301
    private const val BILDIRIM_ID = 7301
    private const val EK_BASLIK = "baslik"
    private const val EK_GOVDE = "govde"

    // ⚠ Sunucunun push'larıyla AYNI kanal (`MainActivity` yaratıyor,
    // `_shared/push.ts` kullanıyor) — ikinci bir kanal kullanıcının
    // ayarlarında ikinci bir anahtar demek olurdu.
    private const val KANAL = "kelimeki_oyun"

    // "Hatırlatma kullanıcıya gösterildi" kanıtı (12 Ekim 2026): alıcı
    // `notify` anında yazar, kur/iptal siler. Dart bunu uygulama açılınca
    // okur — eskiden "saat geçtiyse gösterildi" sayılıyordu ve gösterilmemiş
    // bir hatırlatma oyunu kalıcı olarak kilitliyordu.
    private const val TERCIHLER = "kelimeki_hatirlatma"
    private const val TESLIM = "teslim"

    private fun teslimYaz(context: Context, deger: Boolean) {
        context.getSharedPreferences(TERCIHLER, Context.MODE_PRIVATE)
            .edit().putBoolean(TESLIM, deger).apply()
    }

    /** `{bekliyor, teslim}` — Dart `yarimOyunDurum`. */
    fun durum(context: Context): Map<String, Boolean> {
        val teslim = context.getSharedPreferences(TERCIHLER, Context.MODE_PRIVATE)
            .getBoolean(TESLIM, false)
        // FLAG_NO_CREATE: yalnızca kurulmuş (iptal edilmemiş) istek varsa
        // döner. Alarm çaldıktan sonra da durur, bu yüzden teslimle süzülür.
        val pi = PendingIntent.getBroadcast(
            context,
            ISTEK_KODU,
            Intent(context, YarimOyunAlicisi::class.java),
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
        )
        return mapOf("bekliyor" to (pi != null && !teslim), "teslim" to teslim)
    }

    private fun bekleyen(context: Context, baslik: String?, govde: String?): PendingIntent {
        val intent = Intent(context, YarimOyunAlicisi::class.java).apply {
            if (baslik != null) putExtra(EK_BASLIK, baslik)
            if (govde != null) putExtra(EK_GOVDE, govde)
        }
        return PendingIntent.getBroadcast(
            context,
            ISTEK_KODU,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    fun kur(context: Context, zamanMs: Long, baslik: String, govde: String) {
        val alarm = context.getSystemService(AlarmManager::class.java) ?: return
        teslimYaz(context, false)
        // Aynı istek kodu + FLAG_UPDATE_CURRENT → bekleyen alarm YENİSİYLE
        // değişir; cihazda en fazla BİR hatırlatma olur.
        alarm.setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            zamanMs,
            bekleyen(context, baslik, govde),
        )
    }

    fun iptal(context: Context) {
        teslimYaz(context, false)
        val alarm = context.getSystemService(AlarmManager::class.java) ?: return
        val pi = bekleyen(context, null, null)
        alarm.cancel(pi)
        // PendingIntent'in kendisi de iptal: yoksa `durum` FLAG_NO_CREATE ile
        // onu bulup "bekliyor" derdi.
        pi.cancel()
    }

    fun goster(context: Context, intent: Intent) {
        val baslik = intent.getStringExtra(EK_BASLIK) ?: return
        val govde = intent.getStringExtra(EK_GOVDE) ?: return
        // Android 13+: izin yoksa `notify` sessizce düşer; açıkça kontrol
        // etmek hem niyeti belgeliyor hem lint'i susturuyor.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        val acilis = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val dokunus = acilis?.let {
            PendingIntent.getActivity(
                context,
                ISTEK_KODU,
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, KANAL)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        val bildirim = builder
            // FCM'in varsayılanıyla aynı: uygulama ikonu.
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle(baslik)
            .setContentText(govde)
            .setAutoCancel(true)
            .apply { if (dokunus != null) setContentIntent(dokunus) }
            .build()
        context.getSystemService(NotificationManager::class.java)
            ?.notify(BILDIRIM_ID, bildirim)
        teslimYaz(context, true)
    }
}

/** Alarm çalınca bildirimi gösteren alıcı — manifestte `exported="false"`. */
class YarimOyunAlicisi : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        YarimOyunHatirlatmasi.goster(context, intent)
    }
}
