# Evidencia 02: Cifrado de Información Sensible

## Objetivo
Aplicar mecanismos de cifrado simétrico mediante la función `pgp_sym_encrypt()` de la extensión `pgcrypto` en PostgreSQL para proteger datos sensibles almacenados en reposo, y evaluar su proceso de recuperación mediante descifrado.

---

## Comando o procedimiento
Para llevar a cabo el desarrollo de esta actividad, se ejecutó la siguiente secuencia de pasos en el motor PostgreSQL:

1. **Creación de la estructura:** Se definió la tabla `clientes_protegidos` utilizando una columna de tipo `BYTEA` para almacenar el dato protegido en formato binario cifrado.
2. **Cifrado en reposo:** Se insertó un registro de prueba cifrando el campo del RFC mediante la función `pgp_sym_encrypt()`, proporcionando el texto en claro y una clave secreta de demostración.
3. **Verificación de la protección:** Se realizó una consulta `SELECT` sobre la tabla para comprobar que el dato no permanezca legible a simple vista.
4. **Recuperación del dato:** Se ejecutó una consulta de descifrado utilizando la función `pgp_sym_decrypt()` pasándole la columna cifrada y la clave secreta correspondiente.
5. **Evaluación de llaves e inseguridad:** Se analizaron los comportamientos del sistema al ingresar una clave incorrecta y el riesgo que representa incluir claves dentro de las sentencias SQL.

---

## Resultado obtenido

* **Consulta directa a la tabla:** El campo del RFC no mostró el valor legible (`'LOPA900101ABC'`), sino una secuencia binaria cifrada e incomprensible.
* **Consulta con descifrado correcto:** Al proporcionar la clave exacta (`'CLAVE-DE-PRUEBA'`), la función devolvió exitosamente el texto original en claro.
* **Consulta con clave errónea:** Al intentar descifrar utilizando una clave distinta o incorrecta, el motor PostgreSQL arrojó un error de lectura/descifrado impidiendo el acceso al dato original.

---

## Análisis

### 8.1 Crear una tabla de demostración
![evidencia2](../img/evidencia2.png)

### 8.2 Respuestas a las Preguntas

* **1. ¿Qué diferencia existe entre `crypt()` y `pgp_sym_encrypt()`?**  
  `crypt()` es una función de **hash/derivación de claves** (unidireccional), diseñada para autenticar sin posibilidad de recuperar el texto original. Por su parte, `pgp_sym_encrypt()` es una función de **cifrado simétrico** (bidireccional), diseñada para proteger un dato que requiere ser recuperado posteriormente mediante el uso de una clave secreta.

* **2. ¿Cuál de los dos mecanismos permite recuperar el dato original?**  
  El mecanismo de cifrado simétrico (`pgp_sym_encrypt()`), ya que mediante el proceso de descifrado (`pgp_sym_decrypt()`) y la clave correcta se puede obtener nuevamente el valor original.

* **3. ¿Qué ocurre si se utiliza una clave incorrecta?**  
  El motor de base de datos no puede descifrar la información y genera un error criptográfico, protegiendo el contenido y evitando que personas sin la clave autorizada accedan al dato real.

* **4. ¿Qué problema de seguridad representa colocar la clave directamente en una consulta?**  
  Colocar la clave (*hardcoded secret*) directamente en la consulta SQL expone la contraseña criptográfica en el historial de comandos del cliente, en los registros del servidor (*logs*), en scripts guardados, en capturas de pantalla y en repositorios de código como GitLab, anulando por completo la efectividad del cifrado.

---

## Conclusión
El cifrado simétrico en reposo mediante `pgp_sym_encrypt()` es la técnica adecuada cuando se requiere proteger información sensible (como RFC, números de tarjeta o datos financieros) que deba ser recuperada en su estado original por usuarios o aplicaciones autorizadas. Sin embargo, la seguridad del cifrado depende por completo de una correcta gestión de claves; escribir la clave directamente en las consultas SQL expone la información ante cualquier persona con acceso a los archivos o registros del sistema.