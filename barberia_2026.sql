

Use Master
go

if exists(Select * from sys.databases Where name='Barberia2026')
Begin
	Alter Database Barberia2026 Set Single_User With Rollback Immediate
	Drop Database Barberia2026
End
go

create database Barberia2026
go

USE Barberia2026
go

set dateformat ymd
go

/* TABLAS */

CREATE TABLE tb_cargos (
  IdCargo int primary key,
  NombreCargo varchar(30) not null
)
go

CREATE TABLE tb_empleados (
  IdEmpleado int identity(1,1) primary key,
  ApeEmpleado varchar(50) not null,
  NomEmpleado varchar(50) not null,
  FonoEmpleado varchar(15) null,
  IdCargo int references tb_cargos,
  Estado char(1) not null default('A')   -- A = Activo, I = Inactivo
)
go

CREATE TABLE tb_clientes (
  IdCliente char(8) primary key,        -- DNI
  ApeCliente varchar(50) not null,
  NomCliente varchar(50) not null,
  FonoCliente varchar(15) null
)
go

CREATE TABLE tb_servicios (
  IdServicio int identity(1,1) primary key,
  NombreServicio varchar(50) not null,
  Precio decimal(10,2) not null,
  DuracionMin int not null default(30)
)
go

-- Una cita = un cliente + un barbero + un servicio
CREATE TABLE tb_citas (
  IdCita int identity(1,1) primary key,
  Fecha date not null,
  Hora varchar(5) not null,                 -- ejemplo '10:30'
  IdCliente char(8) references tb_clientes,
  IdEmpleado int references tb_empleados,   -- barbero
  IdServicio int references tb_servicios,
  Precio decimal(10,2) not null,
  Estado char(1) not null default('P'),     -- P = Pendiente, A = Atendida, C = Cancelada
  TipoPago varchar(10) null                 -- Efectivo, Yape, Plin, Tarjeta
)
go

CREATE TABLE tb_productos (
  IdProducto int identity(1,1) primary key,
  NombreProducto varchar(50) not null,
  Precio decimal(10,2) not null,
  Stock int not null default(0),
  StockMinimo int not null default(5)       -- alerta: si Stock <= StockMinimo sale en el reporte de bajo stock
)
go

-- Una venta = un producto (simple, sin tabla de detalle)
CREATE TABLE tb_ventas (
  IdVenta int identity(1,1) primary key,
  Fecha datetime not null default(getdate()),
  IdCliente char(8) null references tb_clientes,   -- opcional (cliente ocasional)
  IdProducto int references tb_productos,
  Cantidad int not null,
  PrecioUnit decimal(10,2) not null,
  Total decimal(10,2) not null,
  TipoPago varchar(10) not null                    -- Efectivo, Yape, Plin, Tarjeta
)
go

CREATE TABLE tb_ingresos (
  IdIngreso int identity(1,1) primary key,
  Fecha datetime not null default(getdate()),
  IdProducto int references tb_productos,
  Cantidad int not null,
  CostoUnit decimal(10,2) not null default(0)
)
go

/* ===================== DATOS DE PRUEBA ===================== */

INSERT INTO tb_cargos VALUES (1, 'Administrador')
INSERT INTO tb_cargos VALUES (2, 'Recepcionista')
INSERT INTO tb_cargos VALUES (3, 'Barbero')
go

INSERT INTO tb_empleados VALUES ('Leon','Gianfranco','987654321',1,'A')
INSERT INTO tb_empleados VALUES ('Carrillo','Juan','987654324',2,'A')
INSERT INTO tb_empleados VALUES ('Maldonado','Dante','987654322',3,'A')
INSERT INTO tb_empleados VALUES ('Raa','Fernando','987654323',3,'A')
go

INSERT INTO tb_clientes VALUES ('46458146','Oviedo','Daniel','936724317')
INSERT INTO tb_clientes VALUES ('45545253','Gonzales','Jhonatan','937724318')
INSERT INTO tb_clientes VALUES ('47565417','Silva','George','936024320')
go

INSERT INTO tb_servicios VALUES ('Corte de cabello Clasico',40.00,30)
INSERT INTO tb_servicios VALUES ('Corte y barba',50.00,45)
INSERT INTO tb_servicios VALUES ('Corte de cabello con diseño',60.00,20)
INSERT INTO tb_servicios VALUES ('Corte infantil',30.00,30)
go

-- Los DNI de los clientes deben existir arriba; el precio es el del servicio
INSERT INTO tb_citas (Fecha, Hora, IdCliente, IdEmpleado, IdServicio, Precio, Estado, TipoPago)
VALUES ('2026-10-16','10:00','46458146',3,1,40.00,'A','Yape')
INSERT INTO tb_citas (Fecha, Hora, IdCliente, IdEmpleado, IdServicio, Precio, Estado, TipoPago)
VALUES ('2026-10-17','11:00','45545253',4,2,50.00,'A','Yape')
INSERT INTO tb_citas (Fecha, Hora, IdCliente, IdEmpleado, IdServicio, Precio, Estado, TipoPago)
VALUES ('2026-10-18','09:30','47565417',3,3,60.00,'P',null)
go

INSERT INTO tb_productos VALUES ('Cera para cabello',30.00,10,5)
INSERT INTO tb_productos VALUES ('The Barberia Shampoo',50.00,3,5)
INSERT INTO tb_productos VALUES ('Gel para afeitar',80.00,8,4)
INSERT INTO tb_productos VALUES ('Polvo Texturizador',60.00,2,4)
go

/* =====================================================
   PROCEDIMIENTOS ALMACENADOS
   ===================================================== */

/* ---------- CARGOS (para el ComboBox de empleados) ---------- */
create or alter proc usp_listar_cargos
As
Begin
	Select IdCargo, NombreCargo From tb_cargos
End
go


/* ---------- CLIENTES ---------- */
create or alter proc usp_listar_clientes
As
Begin
	Select IdCliente as DNI, ApeCliente as Apellido, NomCliente as Nombre, FonoCliente as Telefono
	From tb_clientes
End
go

create or alter proc usp_buscar_clientes
@texto varchar(50)
As
Begin
	Select IdCliente as DNI, ApeCliente as Apellido, NomCliente as Nombre, FonoCliente as Telefono
	From tb_clientes
	Where ApeCliente Like @texto + '%' Or IdCliente Like @texto + '%'
End
go

create or alter proc usp_agregar_cliente
@dni char(8),
@ape varchar(50),
@nom varchar(50),
@fono varchar(15)
As
Begin
	Insert Into tb_clientes Values (@dni, @ape, @nom, @fono)
End
go

create or alter proc usp_modificar_cliente
@dni char(8),
@ape varchar(50),
@nom varchar(50),
@fono varchar(15)
As
Begin
	Update tb_clientes
	Set ApeCliente = @ape, NomCliente = @nom, FonoCliente = @fono
	Where IdCliente = @dni
End
go

create or alter proc usp_eliminar_cliente
@dni char(8)
As
Begin
	Delete From tb_clientes Where IdCliente = @dni
End
go


/* ---------- EMPLEADOS ---------- */
create or alter proc usp_listar_empleados
As
Begin
	Select e.IdEmpleado as Codigo, e.ApeEmpleado as Apellido, e.NomEmpleado as Nombre,
	       e.FonoEmpleado as Telefono, c.NombreCargo as Cargo,
	       Case e.Estado When 'A' Then 'Activo' Else 'Inactivo' End as Estado
	From tb_empleados e
	Inner Join tb_cargos c On e.IdCargo = c.IdCargo
End
go

-- Solo barberos activos (para el ComboBox al registrar una cita)
create or alter proc usp_listar_barberos
As
Begin
	Select IdEmpleado, ApeEmpleado + ' ' + NomEmpleado as Barbero
	From tb_empleados
	Where IdCargo = 3 And Estado = 'A'
End
go

create or alter proc usp_buscar_empleados
@ape varchar(50)
As
Begin
	Select e.IdEmpleado as Codigo, e.ApeEmpleado as Apellido, e.NomEmpleado as Nombre,
	       e.FonoEmpleado as Telefono, c.NombreCargo as Cargo
	From tb_empleados e
	Inner Join tb_cargos c On e.IdCargo = c.IdCargo
	Where e.ApeEmpleado Like @ape + '%'
End
go

create or alter proc usp_agregar_empleado
@ape varchar(50),
@nom varchar(50),
@fono varchar(15),
@idcargo int
As
Begin
	Insert Into tb_empleados (ApeEmpleado, NomEmpleado, FonoEmpleado, IdCargo)
	Values (@ape, @nom, @fono, @idcargo)
End
go

create or alter proc usp_modificar_empleado
@id int,
@ape varchar(50),
@nom varchar(50),
@fono varchar(15),
@idcargo int
As
Begin
	Update tb_empleados
	Set ApeEmpleado = @ape, NomEmpleado = @nom, FonoEmpleado = @fono, IdCargo = @idcargo
	Where IdEmpleado = @id
End
go

-- No se borra, se pasa a Inactivo (evita errores de llaves foraneas con las citas)
create or alter proc usp_eliminar_empleado
@id int
As
Begin
	Update tb_empleados Set Estado = 'I' Where IdEmpleado = @id
End
go


/* ---------- SERVICIOS ---------- */
create or alter proc usp_listar_servicios
As
Begin
	Select IdServicio as Codigo, NombreServicio as Servicio, Precio, DuracionMin as Duracion
	From tb_servicios
End
go

create or alter proc usp_buscar_servicios
@texto varchar(50)
As
Begin
	Select IdServicio as Codigo, NombreServicio as Servicio, Precio, DuracionMin as Duracion
	From tb_servicios
	Where NombreServicio Like @texto + '%'
End
go

create or alter proc usp_agregar_servicio
@nombre varchar(50),
@precio decimal(10,2),
@duracion int
As
Begin
	Insert Into tb_servicios Values (@nombre, @precio, @duracion)
End
go

create or alter proc usp_modificar_servicio
@id int,
@nombre varchar(50),
@precio decimal(10,2),
@duracion int
As
Begin
	Update tb_servicios
	Set NombreServicio = @nombre, Precio = @precio, DuracionMin = @duracion
	Where IdServicio = @id
End
go

create or alter proc usp_eliminar_servicio
@id int
As
Begin
	Delete From tb_servicios Where IdServicio = @id
End
go


/* ---------- PRODUCTOS ---------- */
create or alter proc usp_listar_productos
As
Begin
	Select IdProducto as Codigo, NombreProducto as Producto, Precio, Stock, StockMinimo as Minimo
	From tb_productos
End
go

create or alter proc usp_buscar_productos
@texto varchar(50)
As
Begin
	Select IdProducto as Codigo, NombreProducto as Producto, Precio, Stock, StockMinimo as Minimo
	From tb_productos
	Where NombreProducto Like @texto + '%'
End
go

create or alter proc usp_agregar_producto
@nombre varchar(50),
@precio decimal(10,2),
@stock int,
@minimo int
As
Begin
	Insert Into tb_productos (NombreProducto, Precio, Stock, StockMinimo)
	Values (@nombre, @precio, @stock, @minimo)
End
go

create or alter proc usp_modificar_producto
@id int,
@nombre varchar(50),
@precio decimal(10,2),
@stock int,
@minimo int
As
Begin
	Update tb_productos
	Set NombreProducto = @nombre, Precio = @precio, Stock = @stock, StockMinimo = @minimo
	Where IdProducto = @id
End
go

create or alter proc usp_eliminar_producto
@id int
As
Begin
	Delete From tb_productos Where IdProducto = @id
End
go


/* ---------- CITAS ---------- */
create or alter proc usp_listar_citas
As
Begin
	Select ci.IdCita as Cita, ci.Fecha, ci.Hora,
	       cl.ApeCliente + ' ' + cl.NomCliente as Cliente,
	       e.ApeEmpleado + ' ' + e.NomEmpleado as Barbero,
	       s.NombreServicio as Servicio, ci.Precio,
	       Case ci.Estado When 'P' Then 'Pendiente' When 'A' Then 'Atendida' Else 'Cancelada' End as Estado,
	       ci.TipoPago as Pago
	From tb_citas ci
	Inner Join tb_clientes cl On ci.IdCliente = cl.IdCliente
	Inner Join tb_empleados e On ci.IdEmpleado = e.IdEmpleado
	Inner Join tb_servicios s On ci.IdServicio = s.IdServicio
	Order By ci.Fecha, ci.Hora
End
go

-- Filtrar por rango de fechas
create or alter proc usp_listar_citas_fechas
@f1 date,
@f2 date
As
Begin
	Select ci.IdCita as Cita, ci.Fecha, ci.Hora,
	       cl.ApeCliente + ' ' + cl.NomCliente as Cliente,
	       e.ApeEmpleado + ' ' + e.NomEmpleado as Barbero,
	       s.NombreServicio as Servicio, ci.Precio,
	       Case ci.Estado When 'P' Then 'Pendiente' When 'A' Then 'Atendida' Else 'Cancelada' End as Estado,
	       ci.TipoPago as Pago
	From tb_citas ci
	Inner Join tb_clientes cl On ci.IdCliente = cl.IdCliente
	Inner Join tb_empleados e On ci.IdEmpleado = e.IdEmpleado
	Inner Join tb_servicios s On ci.IdServicio = s.IdServicio
	Where ci.Fecha Between @f1 And @f2
	Order By ci.Fecha, ci.Hora
End
go

-- Historial de un cliente por DNI
create or alter proc usp_historial_cliente
@dni char(8)
As
Begin
	Select ci.IdCita as Cita, ci.Fecha, ci.Hora, s.NombreServicio as Servicio, ci.Precio,
	       Case ci.Estado When 'P' Then 'Pendiente' When 'A' Then 'Atendida' Else 'Cancelada' End as Estado
	From tb_citas ci
	Inner Join tb_servicios s On ci.IdServicio = s.IdServicio
	Where ci.IdCliente = @dni
	Order By ci.Fecha Desc
End
go

-- El precio se toma del servicio automaticamente (sin triggers)
-- Valida que el barbero no tenga otra cita a la misma fecha y hora
create or alter proc usp_agregar_cita
@fecha date,
@hora varchar(5),
@dni char(8),
@idbarbero int,
@idservicio int
As
Begin
	If Exists (Select 1 From tb_citas
	           Where Fecha = @fecha And Hora = @hora And IdEmpleado = @idbarbero And Estado <> 'C')
	Begin
		Raiserror('El barbero ya tiene una cita en esa fecha y hora', 16, 1)
		Return
	End

	Insert Into tb_citas (Fecha, Hora, IdCliente, IdEmpleado, IdServicio, Precio)
	Select @fecha, @hora, @dni, @idbarbero, @idservicio, Precio
	From tb_servicios Where IdServicio = @idservicio
End
go

create or alter proc usp_modificar_cita
@id int,
@fecha date,
@hora varchar(5),
@idbarbero int,
@idservicio int
As
Begin
	If Exists (Select 1 From tb_citas
	           Where Fecha = @fecha And Hora = @hora And IdEmpleado = @idbarbero
	             And Estado <> 'C' And IdCita <> @id)
	Begin
		Raiserror('El barbero ya tiene una cita en esa fecha y hora', 16, 1)
		Return
	End

	Update tb_citas
	Set Fecha = @fecha, Hora = @hora, IdEmpleado = @idbarbero, IdServicio = @idservicio,
	    Precio = (Select Precio From tb_servicios Where IdServicio = @idservicio)
	Where IdCita = @id
End
go

create or alter proc usp_cancelar_cita
@id int
As
Begin
	Update tb_citas Set Estado = 'C' Where IdCita = @id
End
go

create or alter proc usp_eliminar_cita
@id int
As
Begin
	Delete From tb_citas Where IdCita = @id
End
go


/* ---------- PAGOS (de citas) ---------- */
create or alter proc usp_listar_citas_pendientes
As
Begin
	Select ci.IdCita as Cita, ci.Fecha, ci.Hora,
	       cl.ApeCliente + ' ' + cl.NomCliente as Cliente,
	       s.NombreServicio as Servicio, ci.Precio
	From tb_citas ci
	Inner Join tb_clientes cl On ci.IdCliente = cl.IdCliente
	Inner Join tb_servicios s On ci.IdServicio = s.IdServicio
	Where ci.Estado = 'P'
	Order By ci.Fecha, ci.Hora
End
go

-- Registrar el pago: marca la cita como Atendida
create or alter proc usp_pagar_cita
@id int,
@tipopago varchar(10)
As
Begin
	Update tb_citas Set Estado = 'A', TipoPago = @tipopago Where IdCita = @id
End
go


/* ---------- VENTAS DE PRODUCTOS (sin triggers: el procedimiento descuenta el stock) ---------- */
create or alter proc usp_registrar_venta
@dni char(8),            -- puede ser NULL (cliente ocasional)
@idproducto int,
@cantidad int,
@tipopago varchar(10)
As
Begin
	Declare @precio decimal(10,2), @stock int

	If @cantidad <= 0
	Begin
		Raiserror('La cantidad debe ser mayor a 0', 16, 1)
		Return
	End

	Select @precio = Precio, @stock = Stock From tb_productos Where IdProducto = @idproducto

	If @cantidad > @stock
	Begin
		Raiserror('No hay stock suficiente para esta venta', 16, 1)
		Return
	End

	Insert Into tb_ventas (IdCliente, IdProducto, Cantidad, PrecioUnit, Total, TipoPago)
	Values (@dni, @idproducto, @cantidad, @precio, @precio * @cantidad, @tipopago)

	Update tb_productos Set Stock = Stock - @cantidad Where IdProducto = @idproducto
End
go

create or alter proc usp_listar_ventas
As
Begin
	Select v.IdVenta as Venta, v.Fecha,
	       IsNull(c.ApeCliente + ' ' + c.NomCliente, 'Cliente ocasional') as Cliente,
	       p.NombreProducto as Producto, v.Cantidad, v.PrecioUnit as Precio, v.Total, v.TipoPago as Pago
	From tb_ventas v
	Inner Join tb_productos p On v.IdProducto = p.IdProducto
	Left Join tb_clientes c On v.IdCliente = c.IdCliente
	Order By v.Fecha Desc
End
go

-- Anular: borra la venta y devuelve el stock
create or alter proc usp_anular_venta
@id int
As
Begin
	Update p
	Set p.Stock = p.Stock + v.Cantidad
	From tb_productos p
	Inner Join tb_ventas v On p.IdProducto = v.IdProducto
	Where v.IdVenta = @id

	Delete From tb_ventas Where IdVenta = @id
End
go


/* ---------- INGRESO DE STOCK ---------- */
create or alter proc usp_registrar_ingreso
@idproducto int,
@cantidad int,
@costo decimal(10,2)
As
Begin
	If @cantidad <= 0
	Begin
		Raiserror('La cantidad debe ser mayor a 0', 16, 1)
		Return
	End

	Insert Into tb_ingresos (IdProducto, Cantidad, CostoUnit)
	Values (@idproducto, @cantidad, @costo)

	Update tb_productos Set Stock = Stock + @cantidad Where IdProducto = @idproducto
End
go

create or alter proc usp_listar_ingresos
As
Begin
	Select i.IdIngreso as Codigo, i.Fecha, p.NombreProducto as Producto,
	       i.Cantidad, i.CostoUnit as Costo
	From tb_ingresos i
	Inner Join tb_productos p On i.IdProducto = p.IdProducto
	Order By i.Fecha Desc
End
go


/* ---------- CONSULTAS Y REPORTES ---------- */
create or alter proc usp_reporte_ventas
@f1 date,
@f2 date
As
Begin
	Select v.IdVenta as Venta, v.Fecha, p.NombreProducto as Producto,
	       v.Cantidad, v.PrecioUnit as Precio, v.Total, v.TipoPago as Pago
	From tb_ventas v
	Inner Join tb_productos p On v.IdProducto = p.IdProducto
	Where Cast(v.Fecha as date) Between @f1 And @f2
	Order By v.Fecha
End
go

create or alter proc usp_productos_bajo_stock
As
Begin
	Select IdProducto as Codigo, NombreProducto as Producto, Stock, StockMinimo as Minimo
	From tb_productos
	Where Stock <= StockMinimo
End
go

-- Ingresos por barbero entre dos fechas (solo citas atendidas)
create or alter proc usp_reporte_ingresos
@f1 date,
@f2 date
As
Begin
	Select e.ApeEmpleado + ' ' + e.NomEmpleado as Barbero,
	       Count(*) as Cantidad, Sum(ci.Precio) as Total
	From tb_citas ci
	Inner Join tb_empleados e On ci.IdEmpleado = e.IdEmpleado
	Where ci.Estado = 'A' And ci.Fecha Between @f1 And @f2
	Group By e.ApeEmpleado, e.NomEmpleado
End
go


