# Informe Final: Laboratorio 02 — Cifrado, Credenciales y Comunicaciones Seguras

**Curso:** Gestión de Seguridad y Fundamentos de Base de Datos  
**Alumno:** Ana Maribel Felipe Rodriguez

---

## 1. Introducción
En la administración de bases de datos, los esquemas de control de acceso (usuarios, roles y permisos) son fundamentales pero insuficientes para garantizar por sí solos la seguridad de la información. Una base de datos bien configurada a nivel de permisos sigue siendo vulnerable si almacena contraseñas o datos sensibles en texto claro, transmite información sin cifrar por la red, incluye claves criptográficas dentro de sus scripts o no protege sus archivos de respaldo.

Este laboratorio aborda de manera integral la protección de credenciales, el cifrado de datos sensibles en reposo, la seguridad de las comunicaciones en tránsito mediante el protocolo TLS y la correcta gestión del ciclo de vida de las claves criptográficas en PostgreSQL 16.

---

## 2. Protección de Credenciales
Para proteger el acceso a los sistemas es imprescindible comprender las diferencias estructurales entre los distintos formatos de almacenamiento de información:

* **Texto claro (*Plaintext*):** Datos almacenados en su forma legible original. Si una base de datos sufre una filtración, las contraseñas guardadas en texto claro quedan inmediatamente expuestas de forma masiva.
* **Hash / Derivación de claves:** Algoritmo unidireccional no reversible (como `crypt` con bcrypt o Argon2id) diseñado específicamente para verificar contraseñas agregando un valor aleatorio (*sal* o *salt*). Permite validar la credencial sin necesidad de conocer o almacenar la clave original.
* **Cifrado simétrico/asimétrico:** Algoritmo bidireccional reversible mediante el uso de una clave secreta. Está diseñado para proteger datos que **sí requieren ser recuperados** en su estado original en el futuro (como un RFC o un número de tarjeta).

---

## 3. Protección de Datos Sensibles
En este laboratorio se aplicó cifrado simétrico en reposo mediante la función `pgp_sym_encrypt()` de la extensión `pgcrypto` sobre el campo del **RFC de los clientes** (almacenado en una columna de tipo `BYTEA`).

* **¿Por qué se protegió esta información?** El RFC es un dato de identificación personal/fiscal regulado por leyes de privacidad de datos. A diferencia de una contraseña, el RFC debe ser recuperado en texto claro por las aplicaciones autorizadas para procesos de facturación o reportes fiscales, por lo que el uso de cifrado reversible mediante clave secreta (`pgp_sym_decrypt()`) es la técnica adecuada.

---

## 4. TLS (Transport Layer Security)
El protocolo TLS protege la información en tránsito mientras viaja a través de la red entre las aplicaciones/clientes y el servidor motor de PostgreSQL.

* **Problema que resuelve:** Evita que un atacante con acceso al tráfico de red (*sniffing*) o posicionado en la comunicación (*Man-in-the-Middle*) pueda leer en texto claro las consultas SQL, los resultados de la base de datos o las credenciales enviadas durante el inicio de sesión.
* **Verificación realizada en PostgreSQL:** Se inspeccionaron los parámetros globales (`SHOW ssl;`, `SHOW ssl_min_protocol_version;`) y se consultó la vista de sistema `pg_stat_ssl` mediante la instrucción `SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();`. Se constató que cuando el servidor no tiene activo SSL (`ssl = off`), las conexiones cliente mediante `sslmode=prefer` degradan a una sesión no cifrada (`ssl = f`), lo que resalta la necesidad de configurar `ssl = on` y exigir el parámetro estricto `sslmode=require` o `sslmode=verify-full`.

---

## 5. Gestión de Claves
Las claves criptográficas no deben almacenarse dentro de los scripts SQL, archivos de configuración o código fuente (*hardcoded secrets*).

* **Impacto de la mala práctica:** Guardar una clave dentro de un script SQL expone el secreto en los registros del servidor (*logs*), en el historial de ejecuciones, en capturas de pantalla y, de manera crítica, en el historial permanente de Git.
* **Principios de gestión:** El repositorio de código no es un almacén de secretos. Las claves criptográficas deben administrarse mediante gestores dedicados (*Vaults* / *KMS*) o variables de entorno del sistema operativo, totalmente desacopladas del código fuente.

---

## 6. Resultados
1. **Credenciales protegidas:** Se implementó `usuarios_segura` utilizando `crypt()` con sales aleatorias (`gen_salt('bf')`), comprobando que cada hash generado es único e irremplazable y permitiendo la autenticación sin guardar la clave real.
2. **Cifrado en reposo:** Se protegió la tabla `clientes_protegidos`, logrando que la consulta directa muestre una cadena binaria incomprensible y que solo los usuarios con la clave correcta puedan descifrar el RFC.
3. **Validación de canal TLS:** Se documentó el comportamiento de la vista `pg_stat_ssl` tanto en escenarios protegidos como en intentos de conexión con parámetros permisivos.
4. **Gobierno y políticas:** Se estructuró la matriz de comparación de mecanismos de seguridad (`07-comparacion.md`), el análisis de riesgos de arquitectura (`08-analisis-escenario.md`) y una política institucional de 8 reglas para el ciclo de vida de las claves (`10-politica-claves.md`).

---

## 7. Problemas Encontrados
1. **Error de ejecución de `psql` en Windows PowerShell:** Inicialmente el comando `psql` no era reconocido por falta de configuración de la variable de entorno `PATH`. **Solución:** Se utilizó el operador de invocación con la ruta completa hacia el ejecutable: `& "C:\Program Files\PostgreSQL\16\bin\psql.exe"`.
2. **Error al intentar conectar por nombre de host (`anama`):** Se obtuvo `no se pudo traducir el nombre «anama» a una dirección`. **Solución:** Se corrigió el parámetro de conexión indicando el host local explícito (`host=localhost`).
3. **Rechazo de conexión con `sslmode=require`:** La terminal arrojó el error `el servidor no soporta SSL, pero SSL es requerida`. **Solución:** Se identificó que la instalación local de PostgreSQL en Windows viene con `ssl = off` por defecto en `postgresql.conf`, lo que requirió conectarse con `sslmode=prefer` para analizar el comportamiento no cifrado (`ssl = f`) en la vista `pg_stat_ssl`.
4. **Fallo de autenticación por contraseña (`FATAL: la autentificación password falló`):** Ocurrió al intentar ingresar con el usuario `anama`. **Solución:** Se estableció la conexión utilizando el usuario superadministrador `postgres` y la contraseña asignada durante la instalación.

---

## 8. Conclusiones

### Aprendizajes Clave
Se comprendió que la seguridad en bases de datos requiere una estrategia de **defensa en profundidad**. Cifrar tablas no sirve de nada si la red transmite datos en texto claro, y usar TLS es inútil si las credenciales están guardadas en texto plano en la base de datos o si las claves están escritas dentro del código subido a GitLab.

### Medidas en un Entorno Productivo
1. **Almacenamiento de contraseñas:** Implementar derivación de clave con Argon2id o bcrypt mediante la capa de aplicación o marcos de desarrollo (*frameworks*).
2. **Habilitar TLS obligatorio:** Configurar `ssl = on` con versiones mínimas `TLSv1.2` / `TLSv1.3` en PostgreSQL y forzar el parámetro `sslmode=verify-full` en las cadenas de conexión de los clientes.
3. **Gestión de secretos:** Implementar una bóveda de claves (*HashiCorp Vault* o *AWS KMS*) para inyectar claves dinámicamente mediante variables de entorno en lugar de escribirlas en código.
4. **Seguridad en CI/CD:** Incorporar escaneos automáticos de código (*Secret Detection*) en GitLab para evitar que commits con tokens o contraseñas sean integrados al repositorio.

---

## 9. Preguntas de Reflexión

1. **¿Por qué una contraseña no debe almacenarse como texto claro?**  
   Porque cualquier persona con acceso de lectura a la base de datos, a un respaldo o a los registros de auditoría podría obtener las credenciales y suplantar la identidad de los usuarios de forma inmediata.
2. **¿Por qué un hash no es equivalente a un cifrado?**  
   Porque el hash es una función matemática unidireccional (no reversible) diseñada para autenticar sin recuperar el dato original, mientras que el cifrado es una operación bidireccional (reversible) diseñada para proteger un dato que requiere ser leído en texto claro posteriormente mediante una clave.
3. **¿Por qué el cifrado de una columna no sustituye al control de acceso?**  
   Porque el control de acceso define **quién** tiene permiso de interactuar con los objetos del motor, mientras que el cifrado garantiza la **confidencialidad** del contenido en caso de que alguien evada el control de acceso o acceda directamente a los archivos físicos de datos o respaldos.
4. **¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?**  
   Porque TLS únicamente asegura la canal de comunicación en la red (protección en tránsito), pero no verifica qué permisos o tablas tiene derecho a consultar el usuario una vez dentro de la base de datos.
5. **¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?**  
   La información cifrada se volvería **irrecuperable de forma permanente**, generando una pérdida total de datos dado que los algoritmos criptográficos modernos son matemáticamente invulnerables sin el material de la clave.
6. **¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?**  
   La clave debe considerarse **inmediatamente comprometida**. Cualquier persona con acceso al historial del repositorio podría extraerla y descifrar la información protegida de la organización.
7. **¿Por qué un repositorio privado no debe considerarse un almacén de secretos?**  
   Porque el historial de Git mantiene copias permanentes de todos los cambios realizados, distribuyendo los secretos entre todos los desarrolladores que clonan el proyecto y aumentando masivamente la superficie de exposición ante filtraciones.
8. **¿Qué diferencia existe entre proteger información almacenada y proteger información durante su transmisión?**  
   Proteger información almacenada (*At Rest*) resguarda los datos físicos en disco contra robos o accesos no autorizados a las tablas; proteger información en transmisión (*In Transit*) resguarda los paquetes de datos que viajan por los cables o antenas de red contra intercepciones (*sniffing*).
9. **¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?**  
   Porque el algoritmo criptográfico más complejo del mundo queda completamente inutilizado si la clave secreta que lo controla es robada, adivinada o almacenada en un lugar inseguro.
10. **¿Qué mecanismo adicional implementarías en una organización para proteger los respaldos de las bases de datos?**  
    Implementaría un esquema de **cifrado de respaldos en reposo** utilizando herramientas como GPG o AES-256 antes de enviar los archivos de copia de seguridad a servidores secundarios o almacenamiento en la nube, resguardando la clave de cifrado del respaldo en un gestor de secretos externo.