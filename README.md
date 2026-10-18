# Rey Barba – Sistema de gestión de citas y clientes

Prototipo funcional y simple del Sistema Web de Gestión de Citas y Clientes para la barbería **Rey Barba** (Grupo N.° 02). 


## Funcionalidades

|Módulo|Qué permite hacer|
|-|-|
|**Clientes**|Registrar y eliminar clientes. Ver el historial de citas de cada uno.|
|**Barberos**|Registrar barberos, activarlos o desactivarlos y eliminarlos.|
|**Servicios**|Registrar servicios con nombre, duración y precio.|
|**Citas**|Registrar citas (cliente, barbero, servicio, fecha y hora) y cambiar su estado: `pendiente`, `confirmada`, `cancelada` o `completada`.|
|**Pagos**|Registrar el pago de una cita con su monto y método (`yape`, `plin`, `transferencia` o `efectivo`). Muestra el total recaudado.|
|**Roles**|Selector "Ingresar como" para simular el control de acceso.|

### Roles

|Rol|Qué ve y qué puede hacer|
|-|-|
|**Administrador**|Todos los módulos: clientes, barberos, servicios, citas y pagos.|
|**Barbero**|Solo su propia agenda de citas (puede cambiar su estado) y el listado de clientes con su historial.|

### Reglas básicas del sistema

* Un cliente, barbero o servicio **no se puede eliminar** si tiene citas asociadas.
* Solo los barberos **activos** aparecen al registrar una cita.
* Solo se pueden pagar las citas que **no estén canceladas** y que **no tengan un pago** registrado.
* Al elegir una cita en Pagos, el monto se completa con el precio del servicio (se puede modificar).

## Cómo ejecutarlo

1. Descarga o clona el repositorio.
2. Abre el archivo `index.html` en un navegador actual (Chrome, Edge, Firefox o Safari).

No necesitas instalar nada. Para volver a los datos de ejemplo, usa el botón **Restablecer datos de ejemplo** de la parte superior.

## Estructura del proyecto

```
barberia/
├── index.html   # Estructura de la página
├── style.css    # Estilos básicos
├── app.js       # Lógica, datos de ejemplo y pantallas
└── README.md    # Esta documentación
```

## Modelo de datos

Los datos siguen el modelo relacional del informe del proyecto (tablas `clientes`, `barberos`, `citas` y `pagos`), con una tabla adicional `servicios` para el catálogo.

```
clientes (id, nombre, apellido, telefono, email, fecha\_registro)
barberos (id, nombre, especialidad, estado)
servicios (id, nombre, duracion, precio)
citas (id, id\_cliente → clientes, id\_barbero → barberos, id\_servicio → servicios, fecha\_hora, estado)
pagos (id, id\_cita → citas, monto, metodo\_pago, fecha\_pago)
```

Relaciones: un cliente tiene muchas citas, un barbero atiende muchas citas, y cada cita puede tener un pago.

Los datos de ejemplo (5 clientes, 3 barberos, 4 servicios, 6 citas y 2 pagos) están al inicio de `app.js`, en la función `semilla()`. Son inventados y se pueden cambiar.

## Almacenamiento de datos

La información se guarda en el `localStorage` del navegador, con la clave `rey\_barba\_db`. Esto implica que:

* Los datos persisten al recargar la página.
* Son privados de cada navegador y equipo; no se comparten entre usuarios.
* Si se borran los datos del navegador, vuelven a cargarse los datos de ejemplo.

## Tecnologías

* HTML5
* CSS3
* JavaScript (ES6), sin librerías externas

## Mejoras futuras

* Backend (por ejemplo PHP con MySQL o MariaDB) y base de datos compartida.
* Inicio de sesión real con verificación en dos pasos.
* Recordatorios y promociones por WhatsApp.

## Equipo

Grupo N.° 02: Romero, Raez, Navarro y Oviedo.

