-- 8. Actividad 2 — Cifrado de información sensible
-- 8.1 Crear una tabla de demostración
CREATE TABLE clientes_protegidos ( id BIGSERIAL PRIMARY KEY, nombre VARCHAR(120)
NOT NULL, rfc_cifrado BYTEA NOT NULL);

INSERT INTO clientes_protegidos ( nombre, rfc_cifrado) VALUES
( 'Ana López', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));

SELECT * FROM clientes_protegidos;

-- 8.2 Recuperar el dato
SELECT id, nombre, pgp_sym_decrypt( rfc_cifrado, 'CLAVE-DE-PRUEBA' ) AS rfc
FROM clientes_protegidos;