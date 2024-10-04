---primero quiero comprobar el informe detallado de la escena del crimen.

select * from crime_scene_report
where date = '20180115' and lower(City) like '%sql%' and type = 'murder'

--RESULTADO:
--date	  |  type |	description	                                                          |  city
--20180115|	murder|	Security footage shows that there were 2 witnesses.                   |
--                  The first witness lives at the last house on "Northwestern Dr".       |
--                  The second witness, named Annabel, lives somewhere on "Franklin Ave". |	SQL City


--Segun el informe, hay dos testigos clave. Empezaremos examinando al primer testigo, que reside en la 
--ultima casa de Northwestern Drive. Su testimonio puede aportar información valiosa para nuestro caso.

select a.*, b.transcript from person a
left join interview b on a.id = b.person_id
where lower(a.address_street_name) like '%northwestern dr%'
	and a.address_number = (select max(address_number) from person 
						  where lower(address_street_name) like '%northwestern dr%'
						  )

--RESULTADO:
--id	   name	        license_id  address_number  address_street_name  ssn      transcript
--14887 Morty Schapiro  118009	4919	         Northwestern Dr	111564949  I heard a gunshot and [sigue] 
--then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with 
--"48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

--La transcripción revela detalles clave proporcionados por Morty Schapiro. Describe al Sospechoso llevando 
--una bolsa de gimnasio de «Get Fit Now Gym» con un número de socio que empieza por «48Z». Además, Schapiro 
--observó al Sospechoso entrando en un coche con una matrícula que contenía la secuencia «H42W». 
--Basándonos en esta información, ahora podemos llevar a cabo una investigación exhaustiva en nuestra BD.

select a.id gym_id, a.person_id, a.name, a.membership_status status, 
c.plate_number, c. car_make ,c.car_model 
from get_fit_now_member a
left join person b on a.person_id = b.id
left join drivers_license c on b.license_id  = c.id
where a.id like '48Z%' and a.membership_status = 'gold' and c.plate_number like '%H42%W%'

--RESULTADO:
--gym_id	person_id	name	 status	  plate_number	car_make	car_model
--48Z55	     67318	 Jeremy Bowers	gold	0H42W2	   Chevrolet	Spark LS

--Veamos el detalle de la entrevista de Jeremy Bowers con la Policia:
select a.id, a.name, a.address_street_name, a.address_number, b.transcript
from person a
left join interview b on a.id = b.person_id
where a.id = '67318'

--RESULTADO:
--id	name	address_street_name	address_number	transcript
--67318	Jeremy Bowers	Washington Pl, Apt 3A	530	I was hired by a woman with a lot of money. I don't know[sigue] 
--her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. 
--I know that she attended the SQL Symphony Concert 3 times in December 2017. 

--En base a su confesión, fue contratado por una mujer con una altura de alrededor de 1,70 m (65«) 
--o 1,70 m (67»), tiene el pelo rojo, conduce un Tesla Model S y también asistió al Concierto Sinfónico SQL 
--3 veces en diciembre de 2017. Por lo tanto, echemos un vistazo a otro sospechoso.

select b.name, a.*
from drivers_license a
left join person b on a.id = b.license_id
where a.height in ('65','66','67') --no esta seguro en la estatura
	and a.hair_color = 'red'
	and a.car_make = 'Tesla'
	and a.car_model = 'Model S'

--RESULTADO:
--name	id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model
--Miranda Priestly	202298	68	66	green	red	female	500123	Tesla	Model S
--Regina George	291182	65	66	blue	red	female	08CM64	Tesla	Model S
--Red Korb	918773	48	65	black	red	female	917UU3	Tesla	Model S

--Basándonos en sus características físicas y su coche, hemos identificado tres nombres potenciales. 
--Queremos determinar cuál de estos individuos asistió a los Conciertos Sinfónicos de SQL tres veces en 
--diciembre de 2017.

select b.name, a.*
from drivers_license a
left join person b on a.id = b.license_id
left join facebook_event_checkin c on b.id = c.person_id
where a.height in ('65','66','67') --no esta seguro en la estatura
	and a.hair_color = 'red'
	and a.car_make = 'Tesla'
	and a.car_model = 'Model S'
	and c.event_name = 'SQL Symphony Concert'

--RESULTADO:
--name	id	age	height	eye_color	hair_color	gender	plate_number	car_make	car_model
--Miranda Priestly	202298	68	66	green	red	female	500123	Tesla	Model S
--Miranda Priestly	202298	68	66	green	red	female	500123	Tesla	Model S
--Miranda Priestly	202298	68	66	green	red	female	500123	Tesla	Model 

--Miranda Priestly es quien está detrás de este asesinato. Si quieres confirmar si Jeremy Bowers y 
--Miranda Priestly son los sospechosos, debes interrogar a la segunda testigo, Annabel.

select a.*, b.transcript from person a
left join interview b on a.id = b.person_id
where a.name like '%Annabel%' and a.address_street_name like 'Franklin Ave'

--id	name	license_id	address_number	address_street_name	ssn	transcript
--16371	Annabel Miller	490173	103	Franklin Ave	318771143	    I saw the murder happen, and 
--I recognized the killer from my gym when I was working out last week on January the 9th.

--person_id	name	membership_id	check_in_date	check_in_time	check_out_time
--16371	Annabel Miller	90081	20180109	1600	1700

--Sabemos que entrena entre las 16.00 y las 17.00 horas. Entonces podemos ver otras personas que entrenan 
--a esa hora.

select a.name,a.membership_status, b.check_in_date, b.check_in_time, b.check_out_time
from get_fit_now_member a
left join get_fit_now_check_in b on a.id = b.membership_id
where (b. check_in_time = '1600' or check_out_time='1700')

--RESULTADO:
--name	membership_status	check_in_date	check_in_time	check_out_time
--Joe Germuska	gold	20180109	1600	1730
--Jeremy Bowers	gold	20180109	1530	1700
--Annabel Miller	gold	20180109	1600	1700

--Este registro indica que Jeremy Bowes ha reaparecido. Por lo tanto, podemos concluir que Jeremy Bowes 
--es el asesino y Miranda Priestly es la autora intelectual de este crimen.