-- CASO 1: LISTADO DE CLIENTES

SELECT TO_CHAR(c.numrun, 'FM99G999G999',
               'NLS_NUMERIC_CHARACTERS='',.''') || '-' || UPPER(c.dvrun)
           AS "RUT Cliente",
       INITCAP(c.pnombre || ' ' || c.appaterno)
           AS "Nombre Cliente",
       UPPER(p.nombre_prof_ofic)
           AS "Profesión Cliente",
       TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY')
           AS "Fecha de Inscripción",
       NVL(c.direccion, 'SIN DIRECCION')
           AS "Dirección Cliente"
FROM cliente c
INNER JOIN profesion_oficio p
        ON c.cod_prof_ofic = p.cod_prof_ofic
INNER JOIN tipo_cliente tc
        ON c.cod_tipo_cliente = tc.cod_tipo_cliente
WHERE UPPER(tc.nombre_tipo_cliente) = 'TRABAJADORES DEPENDIENTES'
  AND UPPER(p.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
  AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
      (SELECT ROUND(AVG(EXTRACT(YEAR FROM c2.fecha_inscripcion)))
       FROM cliente c2)
ORDER BY c.numrun ASC;


-- CASO 2: AUMENTO DE CREDITO

CREATE TABLE clientes_cupos_compra AS
SELECT TO_CHAR(c.numrun, 'FM9999999990') || '-' || UPPER(c.dvrun)
           AS RUT_CLIENTE,
       TRUNC(MONTHS_BETWEEN(SYSDATE, c.fecha_nacimiento) / 12)
           AS EDAD,
       '$' || TO_CHAR(t.cupo_disp_compra, 'FM999G999G999',
                      'NLS_NUMERIC_CHARACTERS='',.''')
           AS CUPO_DISPONIBLE_COMPRA,
       UPPER(tc.nombre_tipo_cliente)
           AS TIPO_CLIENTE
FROM cliente c
INNER JOIN tarjeta_cliente t
        ON c.numrun = t.numrun
INNER JOIN tipo_cliente tc
        ON c.cod_tipo_cliente = tc.cod_tipo_cliente
WHERE t.cupo_disp_compra >=
      (SELECT MAX(t2.cupo_disp_compra)
       FROM tarjeta_cliente t2
       WHERE EXTRACT(YEAR FROM t2.fecha_solic_tarjeta) =
             EXTRACT(YEAR FROM SYSDATE) - 1)
ORDER BY EDAD ASC;

SELECT RUT_CLIENTE,
       EDAD,
       CUPO_DISPONIBLE_COMPRA,
       TIPO_CLIENTE
FROM clientes_cupos_compra
ORDER BY EDAD ASC;
