# Evidencia 03: El Problema de la Gestión de Claves

## Objetivo
Analizar e identificar los riesgos de seguridad asociados al almacenamiento de claves criptográficas directamente en el código fuente, consultas SQL o scripts (*hardcoded secrets*), y reflexionar sobre el impacto de su exposición pública en repositorios como GitLab.

---

## Comando o procedimiento
Para el desarrollo de esta actividad se siguieron los siguientes pasos:

1. **Creación del archivo demostrativo:** Se generó un archivo SQL temporal (`sql/ejemplo-mala-practica.sql`) incluyendo una consulta de descifrado con la función `pgp_sym_decrypt()` y una clave en texto claro.
2. **Identificación de la mala práctica:** Se analizó la presencia del secreto (*hardcoded secret*) dentro de la instrucción SQL.
3. **Evaluación de vectores de exposición:** Se identificaron los canales y archivos donde queda registrada una clave cuando se escribe directamente en consultas.
4. **Depuración del repositorio:** Se aplicó la regla de laboratorio eliminando el archivo demostrativo para garantizar que ningún secreto o clave de prueba forme parte del historial final del proyecto.

---

## Resultado obtenido

* **En la revisión del script:** Se constató que cualquier persona con acceso de lectura al archivo de código puede visualizar directamente la clave de descifrado sin ningún obstáculo.
* **En el análisis de trazabilidad:** Se verificó que al ejecutar consultas con claves escritas directamente, estas quedan almacenadas en el historial de comandos, en los registros del servidor (*logs*) y en el historial de commits de Git.
* **En la limpieza del repositorio:** Se removió el archivo de prueba antes del commit final para mantener el proyecto libre de credenciales o secretos expuestos.

---

## Análisis

### 9.1 Respuestas al análisis del escenario}

![evidencia3](../img/evidencia3.png)

* **¿Qué ocurriría si esta clave fuera una clave utilizada realmente por una organización y el archivo se publicara en un repositorio Git?**  
  Cualquier persona con acceso al repositorio (o cualquier atacante si el repositorio es público) obtendría la clave secreta directamente. Esto permitiría descifrar de forma inmediata toda la información sensible almacenada en la base de datos (como el RFC de los clientes), anulando por completo la protección que brindaba el cifrado.

### Factores de riesgo de los secretos en código (*hardcoded secrets*)

1. **Persistencia en el historial de Git:** Git registra de forma permanente cada cambio. Aunque en un commit posterior se borre la clave del archivo, seguirá estando disponible en los commits anteriores del historial.
2. **Propagación incontrolada:** El código fuente se distribuye entre múltiples desarrolladores, servidores de integración continua, entornos de prueba y respaldos, multiplicando los puntos donde la clave puede ser filtrada.
3. **Incapacidad de rotación:** Si una clave está escrita directamente en el código de producción, cambiarla requiere modificar el código, volver a probar la aplicación y realizar un nuevo despliegue, en lugar de ser una configuración dinámica e independiente.

---

## Conclusión
Escribir claves criptográficas directamente dentro de los scripts o consultas SQL representa un fallo crítico en la arquitectura de seguridad. El algoritmo criptográfico más robusto se vuelve inútil si la clave de acceso se almacena junto con el código fuente o dentro de un repositorio de control de versiones. Para proteger adecuadamente la información, la gestión de claves debe estar desacoplada del código fuente mediante el uso de variables de entorno de sistema o herramientas dedicadas a la gestión de secretos (*key management systems* / *vaults*).