# Evidencia 08: Análisis de Escenario de Seguridad

## Objetivo
Evaluar integralmente las vulnerabilidades de seguridad en una arquitectura de base de datos que almacena elementos sensibles (credenciales, RFC, información financiera, claves criptográficas) con malas prácticas de implementación, proponiendo las medidas de protección criptográfica y de infraestructura adecuadas para cada componente.

---

## Comando o procedimiento
Para llevar a cabo la evaluación del escenario, se analizaron los 6 elementos almacenados por la organización y las condiciones técnicas descritas:

1. **Revisión de elementos expuestos:** Se identificaron datos sensibles almacenados en texto claro (contraseñas, RFC, información financiera).
2. **Revisión de configuraciones de transmisión:** Se evaluó el riesgo de utilizar conexiones sin validación estricta del servidor.
3. **Revisión de gestión de secretos y respaldos:** Se analizó el impacto de almacenar claves criptográficas en archivos SQL y respaldos sin cifrar.
4. **Matriz de remediación:** Se definió el mecanismo criptográfico correcto para cada uno de los elementos.

---

## Resultado obtenido

* **Identificación de fallos críticos:** Se detectó la presencia de secretos en código (*hardcoded secrets*), ausencia de hashing en credenciales, falta de cifrado en reposo para datos sensibles/respaldos y una configuración permisiva en la capa de transporte.
* **Propuesta de arquitectura segura:** Se estructuró un plan de remediación donde cada activo se resguarda mediante el mecanismo criptográfico o de control correspondiente (hashing, cifrado simétrico, TLS y *vaults* de claves).

---

## Análisis

### 15.1 Respuestas a las Preguntas del Escenario

* **Pregunta 1: ¿Cuáles son los principales riesgos?**
  * **Exposición total de credenciales:** Al guardar contraseñas en texto claro, cualquier filtración de la base de datos o acceso indebido expone directamente las cuentas de los usuarios.
  * **Robo de información sensible (RFC e información financiera):** Al estar en texto plano en las tablas, un atacante con acceso a la base de datos o a los archivos de respaldo puede extraer datos financieros y personales de manera inmediata.
  * **Compromiso total por claves en scripts:** Al colocar claves criptográficas en archivos SQL, cualquier persona con acceso al código o al historial de Git puede obtener las claves y descifrar la información.
  * **Ataques Man-in-the-Middle (MitM):** Una transmisión sin validación adecuada del servidor permite a un atacante en la red interceptar o suplantar la conexión cliente-servidor.
  * **Falta de protección en respaldos:** Un respaldo en texto claro puede ser extraído o extraviado, exponiendo toda la información de la empresa sin pasar por el motor de base de datos.

* **Pregunta 2: ¿Qué mecanismo utilizarías para cada elemento?**
  * **Nombre y Correo electrónico:** Texto plano con controles de acceso por roles (DAC/RBAC) y TLS en tránsito. Si se requiere mayor privacidad en entornos de pruebas, aplicar enmascaramiento o seudonimización.
  * **Contraseña:** Hash y derivación de clave para contraseñas utilizando algoritmo robusto con sal (`crypt` con bcrypt / Argon2id). Nunca debe ser recuperable.
  * **RFC e Información financiera:** Cifrado simétrico en reposo (`pgp_sym_encrypt` o cifrado a nivel de disco/columna mediante AES-256) recuperable solo por usuarios/servicios autorizados.
  * **Claves criptográficas:** Almacenamiento externo mediante un gestor de secretos (*Key Management System* / HashiCorp Vault / Variables de entorno del sistema).
  * **Conexiones cliente-servidor:** Protocolo TLS obligatorio con validación estricta de certificados (`sslmode=verify-full`).
  * **Respaldos:** Cifrado de archivos de respaldo en reposo mediante GPG o AES-256 antes de guardarlos en disco o nube.

* **Pregunta 3: ¿Cuál de los problemas consideras más crítico y por qué?**
  Almacenar las **contraseñas en texto claro** y colocar las **claves criptográficas dentro de archivos SQL** representan los fallos más críticos. Si las claves criptográficas se filtran en el código, el cifrado de cualquier otro dato queda totalmente anulado; y si las contraseñas están en texto plano, la autenticación del sistema pierde toda validez de forma inmediata.

* **Pregunta 4: ¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos? Justifica tu respuesta.**
  **No.** El control de acceso (usuarios y permisos) gestiona únicamente quién puede realizar operaciones dentro de la base de datos en ejecución. Sin embargo:
  1. Si un usuario autorizado o administrador es vulnerado, podrá ver los datos en texto claro porque no están cifrados.
  2. Si alguien obtiene una copia física de los archivos de datos o de los respaldos, los permisos de PostgreSQL no aplican fuera del motor.
  3. Si la red no usa TLS, las credenciales pueden ser capturadas en tránsito aunque el rol tenga permisos restrictivos.

---

## Conclusión
La seguridad en bases de datos exige una estrategia de defensa en profundidad. Los controles de acceso (usuarios y roles) son indispensables pero insuficientes por sí solos si los datos no están protegidos en reposo (hashing y cifrado), en tránsito (TLS) y si los secretos están expuestos en el código fuente. Una arquitectura segura debe separar estrictamente la lógica de negocio de la gestión de credenciales y claves criptográficas.