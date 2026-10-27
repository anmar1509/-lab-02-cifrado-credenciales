# Evidencia 07: Comparación de Protección en Reposo y Protección en Tránsito

## Objetivo
Analizar y clasificar los mecanismos de seguridad criptográfica adecuados para diferentes tipos de información y escenarios dentro de una base de datos, diferenciando entre la protección de datos almacenados (en reposo) y la protección durante la transmisión (en tránsito).

---

## Comando o procedimiento
Para completar esta matriz de comparación se evaluaron las 5 situaciones planteadas en la práctica, identificando el mecanismo criptográfico correspondiente y especificando el activo o propiedad de seguridad que resguarda cada uno:

1. **Contraseña de usuario:** Evaluación de mecanismos de hashing irreversibles con sal.
2. **RFC almacenado en una tabla:** Evaluación de cifrado simétrico reversible.
3. **Consulta enviada desde un cliente al servidor:** Evaluación de seguridad en la capa de red.
4. **Respaldo de una base de datos:** Evaluación de cifrado de archivos de respaldo.
5. **Clave criptográfica:** Evaluación de gestión y almacenamiento seguro de secretos.

---

## Resultado obtenido

### Tabla comparativa de mecanismos de seguridad

| Situación | Mecanismo apropiado | ¿Qué protege? |
| :--- | :--- | :--- |
| **Contraseña de usuario** | Hash / Derivación de claves con sal (`crypt` con bcrypt / Argon2id) | Protege la credencial de acceso contra filtraciones en la base de datos, evitando que la contraseña original pueda ser recuperada o leída. |
| **RFC almacenado en una tabla** | Cifrado simétrico en reposo (`pgp_sym_encrypt` / PGP) | Protege la confidencialidad del dato sensible almacenado en disco, permitiendo su recuperación en texto claro solo a usuarios autorizados con la clave. |
| **Consulta enviada desde un cliente al servidor** | Protocolo de seguridad en tránsito TLS (`sslmode=require` / `verify-full`) | Protege la confidencialidad e integridad de las consultas, credenciales y resultados mientras viajan por la red entre el cliente y PostgreSQL. |
| **Respaldo de una base de datos** | Cifrado de respaldos en reposo (herramientas de cifrado de archivos como GPG / AES-256) | Protege la totalidad de la información contenida en el archivo de dump o copia de seguridad en caso de robo, extravío o acceso no autorizado al almacenamiento. |
| **Clave criptográfica** | Gestión de claves / Bóveda de secretos (*Key Management System* / Variables de entorno / Vault) | Protege el secreto maestro utilizado para cifrar/descifrar, evitando que quede expuesto en scripts, repositorios Git o archivos de configuración. |

---

## Análisis

### Evaluación de conceptos clave

* **Protección en reposo (*At Rest*):** Aplica a los datos que se encuentran almacenados de forma física en discos, tablas o archivos (como el RFC cifrado, los hashes de contraseñas y los respaldos). Su objetivo es evitar que una persona con acceso al almacenamiento o a las tablas lea la información directa.
* **Protección en tránsito (*In Transit*):** Aplica a la información en movimiento que atraviesa interfaces de red (como las consultas SQL y sus respuestas). Su objetivo principal es evitar ataques de interceptación (*sniffing*) o alteración (*man-in-the-middle*).
* **Diferenciación de mecanismos:**
  * Las **contraseñas** no se cifran; se protegen con **hash/derivación de clave** porque nunca deben ser recuperadas, solo verificadas.
  * Los **datos sensibles (RFC)** se **cifran** porque la aplicación necesita recuperar el valor original.
  * Las **claves criptográficas** no se protegen dentro de la misma base de datos, sino mediante un esquema externo de **gestión de secretos**.

---

## Conclusión
Un esquema de seguridad completo en PostgreSQL requiere aplicar la protección adecuada según el estado y la naturaleza de la información. Proteger únicamente la base de datos mediante cifrado de columnas o hashes es inútil si la comunicación viaja en texto claro por la red, así como el uso de TLS no evita la exposición si los datos sensibles están almacenados en texto plano en el disco. La seguridad efectiva se logra combinando cifrado en reposo, TLS en tránsito y una gestión de claves desvinculada del código fuente.