# Evidencia 10: Política Mínima de Protección de Claves Criptográficas

## Objetivo
Establecer un conjunto de reglas y directrices estandarizadas para el ciclo de vida completo de las claves criptográficas dentro de la organización, garantizando la confidencialidad, integridad y gestión segura de los secretos utilizados en las bases de datos.

---

## Comando o procedimiento
Para la elaboración de esta política de seguridad se analizaron las etapas fundamentales del ciclo de vida de una clave y los riesgos asociados al manejo de secretos en entornos de desarrollo y producción:

1. **Definición del alcance:** Se determinó que la política aplica a todas las claves simétricas, asimétricas, tokens y contraseñas maestras utilizadas por las aplicaciones y la base de datos PostgreSQL.
2. **Estructuración de principios:** Se formularon 8 reglas operativas abarcando desde la generación hasta la destrucción definitiva de las claves.
3. **Alineación con buenas prácticas:** Se integraron mecanismos de separación de funciones, desacoplamiento del código fuente y almacenamiento en gestores de secretos dedicados.

---

## Resultado obtenido

### Política de Gestión de Claves Criptográficas

1. **Generación Fuerte:** Todas las claves criptográficas deben ser generadas de forma automatizada mediante generadores de números pseudoaleatorios criptográficamente seguros (CSPRNG) con una longitud mínima de 256 bits para cifrado simétrico (AES/PGP).
2. **Almacenamiento Desacoplado:** Ninguna clave o secreto criptográfico debe almacenarse en el código fuente, scripts SQL o repositorios de control de versiones (GitLab). Las claves se gestionarán exclusivamente mediante un gestor de secretos (*Vault*) o variables de entorno del sistema operativo.
3. **Acceso por Principio de Mínimo Privilegio:** El acceso a las claves de descifrado en producción estará restringido únicamente a los procesos de aplicación autenticados y al personal explícitamente autorizado, manteniendo separación de funciones entre administradores de sistemas y usuarios de base de datos.
4. **Rotación Programada:** Las claves utilitarias deben rotarse de manera periódica (mínimo una vez al año) o de forma inmediata ante cualquier sospecha de compromiso, implementando un esquema que permita reencriptar los datos sin interrupción del servicio.
5. **Respaldo Cifrado:** Los respaldos de las claves maestras deben almacenarse de forma independiente a la base de datos, cifrados con un algoritmo secundario y resguardados en una ubicación físicamente segura o en un almacenamiento secundario fuera del sitio principal.
6. **Revocación e Invalidation:** En caso de filtración o cese de un usuario con acceso privilegiado, la clave afectada debe ser revocada e invalidada inmediatamente en el gestor de secretos, notificando al equipo de seguridad.
7. **Respuesta ante Exposición Accidental:** Si una clave es subida accidentalmente a un repositorio Git (incluso privado), se considerará permanentemente comprometida. Debe ser rotada e invalidada de inmediato y el historial de Git purgado.
8. **Eliminación Segura:** Cuando una clave cumple su ciclo de vida o los datos asociados son depurados, la clave debe destruirse mediante técnicas de borrado seguro (*zeroization* o sobrescritura) garantizando que sea irrecuperable en todos los medios de almacenamiento.

---

## Análisis

### Impacto Operativo y Tecnológico

* **Prevensión de secretos en código (*hardcoded secrets*):** La política erradica la inclusión de parámetros de cifrado en texto claro dentro de las consultas SQL o scripts de migración.
* **Reducción de la superficie de ataque:** Limitar el acceso a las claves mediante *vaults* garantiza que, aunque un atacante logre extraer una copia de la base de datos o de los archivos de respaldo, no pueda leer el contenido cifrado al no poseer el material criptográfico.
* **Garantía en el ciclo de vida:** Definir reglas estrictas para la eliminación y rotación evita el uso de claves obsoletas o débiles en entornos productivos.

---

## Conclusión
La fortaleza de un sistema criptográfico no reside únicamente en la complejidad del algoritmo utilizado, sino en el rigor con el que se gestiona la clave secreta. Una política clara de administración de claves garantiza que la protección en reposo y en tránsito mantenga su efectividad frente a accesos no autorizados, filtraciones accidentales o compromisos de la infraestructura.