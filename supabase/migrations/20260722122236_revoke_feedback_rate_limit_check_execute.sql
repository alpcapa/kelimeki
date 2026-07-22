-- feedback_rate_limit_check yalnızca BEFORE INSERT trigger'ı olarak
-- çağrılmalı; trigger yürütmesi çağıran rolün EXECUTE izninden bağımsızdır,
-- bu yüzden anon/authenticated'den doğrudan RPC çağrısı iznini kaldırmak
-- trigger'ı bozmaz, yalnızca /rest/v1/rpc/feedback_rate_limit_check
-- endpoint'ini kapatır.
revoke execute on function public.feedback_rate_limit_check() from anon, authenticated, public;
