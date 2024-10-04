# SQL Murder Mystery - Solución y Guía

Este proyecto documenta la solucion paso a paso del juego interactivo **SQL Murder Mystery**. El objetivo es resolver un caso de asesinato utilizando consultas SQL para investigar la base de datos y obtener pistas que nos conduzcan a los culpables.

## Solucion del Caso

A continuacion, se detalla el proceso que nos llevo a resolver el caso:

1. ### Consulta Inicial - Informe de la Escena del Crimen
   Primero, consultamos el **informe detallado de la escena del crimen** para obtener informacion sobre el evento:

   ```sql
   SELECT * FROM crime_scene_report
   WHERE date = '20180115' AND LOWER(city) LIKE '%sql%' AND type = 'murder';
   ```

   **Resultado**:
   - Hay **dos testigos** clave.
   - El **primer testigo** vive en la última casa de "Northwestern Dr".
   - El **segundo testigo**, llamado Annabel, reside en algún lugar de "Franklin Ave".

2. ### Interrogatorio al Primer Testigo
   Examinamos al **primer testigo** que vive en la última casa de "Northwestern Dr":

   ```sql
   SELECT a.*, b.transcript 
   FROM person a
   LEFT JOIN interview b ON a.id = b.person_id
   WHERE LOWER(a.address_street_name) LIKE '%northwestern dr%'
     AND a.address_number = (SELECT MAX(address_number) 
                             FROM person 
                             WHERE LOWER(address_street_name) LIKE '%northwestern dr%');
   ```

   **Resultado**:
   - El testigo **Morty Schapiro** observó al sospechoso con una bolsa de gimnasio de "Get Fit Now Gym" con el número de socio comenzando en "48Z".
   - El sospechoso también entró en un coche con la matricula que contiene "H42W".

3. ### Identificacion del Sospechoso
   Investigamos a los miembros del gimnasio "Get Fit Now Gym" que cumplen con las caracteristicas del testimonio:

   ```sql
   SELECT a.id AS gym_id, a.person_id, a.name, a.membership_status AS status, 
          c.plate_number, c.car_make, c.car_model 
   FROM get_fit_now_member a
   LEFT JOIN person b ON a.person_id = b.id
   LEFT JOIN drivers_license c ON b.license_id = c.id
   WHERE a.id LIKE '48Z%' AND a.membership_status = 'gold' 
     AND c.plate_number LIKE '%H42W%';
   ```

   **Resultado**:
   - Se identifico al sospechoso como **Jeremy Bowers**, con un automovil Chevrolet Spark LS.

4. ### Interrogatorio a Jeremy Bowers
   Revisamos la transcripcion de la entrevista de Jeremy Bowers:

   ```sql
   SELECT a.id, a.name, a.address_street_name, a.address_number, b.transcript
   FROM person a
   LEFT JOIN interview b ON a.id = b.person_id
   WHERE a.id = '67318';
   ```

   **Resultado**:
   - Jeremy fue contratado por una **mujer pelirroja** que conduce un Tesla Model S y asistio al **SQL Symphony Concert** tres veces en diciembre de 2017.

5. ### Identificacion de la Autora Intelectual
   Filtramos la base de datos por mujeres con las caracteristicas dadas:

   ```sql
   SELECT b.name, a.*
   FROM drivers_license a
   LEFT JOIN person b ON a.id = b.license_id
   WHERE a.height IN ('65','66','67')
     AND a.hair_color = 'red'
     AND a.car_make = 'Tesla'
     AND a.car_model = 'Model S';
   ```

   **Resultado**:
   - Identificamos tres posibles sospechosas: **Miranda Priestly, Regina George** y **Red Korb**.

6. ### Verificacion de Asistencia al SQL Symphony Concert
   Confirmamos quién de estas sospechosas asistió al SQL Symphony Concert tres veces:

   ```sql
   SELECT b.name, a.*
   FROM drivers_license a
   LEFT JOIN person b ON a.id = b.license_id
   LEFT JOIN facebook_event_checkin c ON b.id = c.person_id
   WHERE a.height IN ('65','66','67')
     AND a.hair_color = 'red'
     AND a.car_make = 'Tesla'
     AND a.car_model = 'Model S'
     AND c.event_name = 'SQL Symphony Concert';
   ```

   **Resultado**:
   - **Miranda Priestly** es lauúnica que asistio tres veces, confirmando que es la autora intelectual del crimen.

7. ### Interrogatorio al Segundo Testigo
   Interrogamos al segundo testigo, **Annabel Miller**:

   ```sql
   SELECT a.*, b.transcript 
   FROM person a
   LEFT JOIN interview b ON a.id = b.person_id
   WHERE a.name LIKE '%Annabel%' AND a.address_street_name LIKE 'Franklin Ave';
   ```

   **Resultado**:
   - Annabel confirma haber visto al asesino en el gimnasio el 9 de enero, alrededor de las 16:00.

8. ### Confirmacion de la Presencia de Jeremy Bowers en el Gimnasio
   Verificamos a las personas presentes en el gimnasio durante esa hora:

   ```sql
   SELECT a.name, a.membership_status, b.check_in_date, b.check_in_time, b.check_out_time
   FROM get_fit_now_member a
   LEFT JOIN get_fit_now_check_in b ON a.id = b.membership_id
   WHERE b.check_in_time = '1600' OR check_out_time = '1700';
   ```

   **Resultado**:
   - Jeremy Bowers estaba presente en el gimnasio a esa hora, lo que confirma su culpabilidad como el asesino.

## Conclusion
- **Jeremy Bowers** es el asesino.
- **Miranda Priestly** es la autora intelectual del crimen.

---