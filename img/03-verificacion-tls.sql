-- 11. Actividad 5 — Verificar el estado de TLS en PostgreSQL
--Consulta:
SHOW ssl;
--También:
SHOW ssl_min_protocol_version;
--Consulta el puerto:
SHOW port;
--Y:
SHOW listen_addresses;

-- 11.1 Verificar la conexión actual
SELECT
inet_client_addr(),
inet_client_port();

-- Ahora verifica si la sesión actual utiliza TLS:
SELECT ssl, version, cipher
FROM pg_stat_ssl
WHERE pid = pg_backend_pid();