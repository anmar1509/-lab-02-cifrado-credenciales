# Evidencia 01: Protección de Credenciales

## Objetivo
Demostrar el riesgo de almacenar contraseñas en texto claro e implementar una técnica segura de derivación de claves (*password hashing*) con sal (*salt*) utilizando la extensión `pgcrypto` en PostgreSQL.

---

## Comando o procedimiento
Para el desarrollo de la actividad se llevaron a cabo los siguientes pasos dentro de la base de datos PostgreSQL:

1. **Habilitación de la extensión criptográfica:** Se ejecutó la sentencia de creación para disponer del módulo `pgcrypto`.
2. **Demostración de la mala práctica:** Se creó la tabla `usuarios_insegura` insertando la contraseña del usuario `'juan'` directamente en texto claro (`'Password123'`) y se consultó la tabla para verificar la exposición del dato.
3. **Generación de representación no reversible:** Se realizaron dos ejecuciones consecutivas de la función de generación de sal aleatoria `gen_salt('bf')` combinada con la función `crypt()` sobre la misma clave original (`'Password123'`) para evaluar la salida del algoritmo Bcrypt.
4. **Implementación de la tabla segura:** Se creó la tabla `usuarios_segura` para guardar únicamente el hash resultante generado por `crypt()` y `gen_salt()`.
5. **Verificación de contraseñas:** Se realizaron pruebas de autenticación evaluando mediante una consulta booleana si la contraseña ingresada producía una coincidencia con el hash almacenado, probando tanto con la clave correcta (`'Password123'`) como con una clave incorrecta (`'OtraPassword'`).

---

## Resultado obtenido

* **En la tabla insegura:** La consulta mostró directamente la palabra `'Password123'` expuesta en texto plano.
* **En la prueba de hash:** Ambas ejecuciones seguidas arrojaron cadenas de texto completamente distintas entre sí (con el formato característico de Bcrypt `$2a$06$...`), demostrando que la sal generó un valor diferente en cada intento.
* **En la tabla segura:** La columna del hash almacenó una cadena ilegible sin revelar en ningún momento la clave original.
* **En la verificación de contraseñas:** La prueba con la contraseña correcta devolvió el resultado booleano `true` (`t`), mientras que la prueba con la contraseña incorrecta devolvió `false` (`f`).

---

## Análisis

### 7.1 El problema
* **¿Qué ocurriría si una persona obtiene acceso de lectura a esta tabla?**  
  Obtendría de forma directa e inmediata las contraseñas de todos los usuarios en texto claro, provocando una filtración grave de credenciales y comprometiendo otros servicios donde los usuarios reutilicen la misma clave.

### 7.3 Generar una representación no reversible
* **1. ¿Son iguales los resultados?**  
  No, los resultados de ambas ejecuciones son completamente diferentes.
* **2. Si no son iguales, ¿por qué?**  
  Porque la función `gen_salt('bf')` genera un valor aleatorio (*sal*) diferente en cada llamada, variando la salida final del hash aunque la contraseña ingresada sea exactamente la misma.
* **3. ¿Qué función cumple `gen_salt()`?**  
  Genera un valor aleatorio único que se combina con la contraseña. Su propósito es evitar que dos usuarios con la misma contraseña tengan hashes iguales y prevenir ataques basados en tablas precalculadas (*rainbow tables*).
* **4. ¿Qué función cumple `crypt()`?**  
  Aplica un algoritmo de derivación de claves / hash unidireccional (*password hashing*) sobre la contraseña combinada con la sal generada.
* **5. ¿Esto es cifrado reversible?**  
  **No.** Es un proceso unidireccional (función hash). No existe ninguna clave ni método para descifrar o revertir el valor generado a su texto original `'Password123'`.

### 7.5 Verificar una contraseña

![evidencia1](./img/evidencia1.png)
* **1. ¿Qué resultado obtuviste con la contraseña correcta?**  
  Se obtuvo el valor `true` (`t`).
* **2. ¿Qué resultado obtuviste con la contraseña incorrecta?**  
  Se obtuvo el valor `false` (`f`).
* **3. ¿Por qué no es necesario recuperar la contraseña original?**  
  Porque para autenticar a un usuario solo se requiere validar que el intento de contraseña ingresado genere exactamente la misma representación matemática (*hash*) que la almacenada en la base de datos.
* **4. ¿Por qué un hash no debe confundirse con cifrado?**  
  El cifrado es un proceso **bidireccional** (diseñado para recuperar los datos usando una clave), mientras que el hash es un proceso **unidireccional** (irreversible y usado exclusivamente para comprobación de integridad y autenticación).

---

## Conclusión
Almacenar contraseñas en texto claro representa una grave vulnerabilidad de seguridad. Para proteger adecuadamente las credenciales es indispensable utilizar algoritmos de derivación de claves (*password hashing*) unidireccionales acompañados de una sal aleatoria (*salt*). Con este método se garantiza que, en caso de una filtración o acceso no autorizado a la base de datos, las contraseñas originales no queden expuestas. 