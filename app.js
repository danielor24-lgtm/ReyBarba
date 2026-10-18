// Sistema local sin base de datos real: los datos se guardan en localStorage del navegador.
const KEY = "rey_barba_db";
const ESTADOS = ["pendiente", "confirmada", "cancelada", "completada"];
const METODOS = ["yape", "plin", "transferencia", "efectivo"];

function semilla() {
  return {
    clientes: [
      { id: 1, nombre: "Juan", apellido: "Pérez", telefono: "987654321", email: "juan.perez@mail.com", fecha_registro: "2026-09-01" },
      { id: 2, nombre: "Diego", apellido: "Ramos", telefono: "987111222", email: "diego.ramos@mail.com", fecha_registro: "2026-09-05" },
      { id: 3, nombre: "Andrés", apellido: "Quispe", telefono: "955333444", email: "", fecha_registro: "2026-09-12" },
      { id: 4, nombre: "Marco", apellido: "Torres", telefono: "944555666", email: "marco.t@mail.com", fecha_registro: "2026-09-20" },
      { id: 5, nombre: "Luis", apellido: "Vega", telefono: "933777888", email: "", fecha_registro: "2026-10-02" }
    ],
    barberos: [
      { id: 1, nombre: "Carlos Mendoza", especialidad: "Cortes clásicos", estado: "activo" },
      { id: 2, nombre: "Miguel Salas", especialidad: "Barba y perfilado", estado: "activo" },
      { id: 3, nombre: "Jorge Díaz", especialidad: "Tratamientos", estado: "inactivo" }
    ],
    servicios: [
      { id: 1, nombre: "Corte de cabello", duracion: 30, precio: 20 },
      { id: 2, nombre: "Arreglo de barba", duracion: 20, precio: 15 },
      { id: 3, nombre: "Corte + barba", duracion: 50, precio: 30 },
      { id: 4, nombre: "Tratamiento capilar", duracion: 40, precio: 35 }
    ],
    citas: [
      { id: 1, id_cliente: 1, id_barbero: 1, id_servicio: 1, fecha_hora: "2026-10-17T10:00", estado: "completada" },
      { id: 2, id_cliente: 2, id_barbero: 2, id_servicio: 2, fecha_hora: "2026-10-17T11:00", estado: "completada" },
      { id: 3, id_cliente: 3, id_barbero: 1, id_servicio: 3, fecha_hora: "2026-10-19T09:30", estado: "confirmada" },
      { id: 4, id_cliente: 4, id_barbero: 2, id_servicio: 1, fecha_hora: "2026-10-19T12:00", estado: "pendiente" },
      { id: 5, id_cliente: 1, id_barbero: 1, id_servicio: 2, fecha_hora: "2026-10-20T16:00", estado: "pendiente" },
      { id: 6, id_cliente: 5, id_barbero: 2, id_servicio: 4, fecha_hora: "2026-10-21T15:00", estado: "cancelada" }
    ],
    pagos: [
      { id: 1, id_cita: 1, monto: 20, metodo_pago: "yape", fecha_pago: "2026-10-17 10:35" },
      { id: 2, id_cita: 2, monto: 15, metodo_pago: "efectivo", fecha_pago: "2026-10-17 11:25" }
    ]
  };
}

let db = JSON.parse(localStorage.getItem(KEY) || "null") || semilla();
let tab = "Citas";
let rol = "admin";          // "admin" o "b<id_barbero>"
let clienteSel = null;      // para ver historial de un cliente

// ---------- utilidades ----------
const val = i => document.getElementById(i).value;
const nuevoId = l => Math.max(0, ...l.map(x => x.id)) + 1;
const get = (l, i) => l.find(x => x.id === Number(i));
const opts = (l, f) => l.map(x => `<option value="${x.id}">${f(x)}</option>`).join("");
const nombreCliente = i => { const c = get(db.clientes, i); return c ? c.nombre + " " + c.apellido : "?"; };
const fmt = f => f.replace("T", " ");
const esAdmin = () => rol === "admin";
const idBarberoRol = () => (esAdmin() ? null : Number(rol.slice(1)));

function guardar() { localStorage.setItem(KEY, JSON.stringify(db)); render(); }
function reiniciar() { db = semilla(); clienteSel = null; guardar(); }
function irA(t) { tab = t; clienteSel = null; render(); }
function cambiarRol() { rol = val("rol"); if (!tabs().includes(tab)) tab = "Citas"; render(); }
function tabs() { return esAdmin() ? ["Clientes", "Barberos", "Servicios", "Citas", "Pagos"] : ["Clientes", "Citas"]; }

function tabla(cabeceras, filas) {
  if (!filas.length) return "<p>No hay registros.</p>";
  return `<table><tr>${cabeceras.map(c => `<th>${c}</th>`).join("")}</tr>` +
    filas.map(f => `<tr>${f.map(c => `<td>${c}</td>`).join("")}</tr>`).join("") + "</table>";
}

// ---------- Clientes ----------
function agregarCliente() {
  db.clientes.push({ id: nuevoId(db.clientes), nombre: val("c_nombre"), apellido: val("c_apellido"),
    telefono: val("c_tel"), email: val("c_email"), fecha_registro: new Date().toISOString().slice(0, 10) });
  guardar();
}
function borrarCliente(id) {
  if (db.citas.some(c => c.id_cliente === id)) return alert("El cliente tiene citas registradas.");
  db.clientes = db.clientes.filter(c => c.id !== id); guardar();
}
function verHistorial(id) { clienteSel = id; render(); }

function vistaClientes() {
  let h = "";
  if (esAdmin()) h += `<div class="caja"><h3>Registrar cliente</h3><div class="form">
    <input id="c_nombre" placeholder="Nombre"><input id="c_apellido" placeholder="Apellido">
    <input id="c_tel" placeholder="Teléfono"><input id="c_email" placeholder="Email">
    <button onclick="agregarCliente()">Registrar cliente</button></div></div>`;
  h += tabla(["ID", "Nombre", "Teléfono", "Email", "Registro", "Acciones"],
    db.clientes.map(c => [c.id, c.nombre + " " + c.apellido, c.telefono, c.email, c.fecha_registro,
      `<button onclick="verHistorial(${c.id})">Historial</button>` +
      (esAdmin() ? `<button onclick="borrarCliente(${c.id})">Eliminar</button>` : "")]));
  if (clienteSel) {
    const cs = db.citas.filter(c => c.id_cliente === clienteSel);
    h += `<div class="caja"><h3>Historial de ${nombreCliente(clienteSel)}</h3>` +
      tabla(["Fecha", "Servicio", "Barbero", "Estado"],
        cs.map(c => [fmt(c.fecha_hora), get(db.servicios, c.id_servicio).nombre, get(db.barberos, c.id_barbero).nombre, c.estado])) + "</div>";
  }
  return h;
}

// ---------- Barberos ----------
function agregarBarbero() {
  db.barberos.push({ id: nuevoId(db.barberos), nombre: val("b_nombre"), especialidad: val("b_esp"), estado: "activo" });
  guardar();
}
function cambiarEstadoBarbero(id) {
  const b = get(db.barberos, id); b.estado = b.estado === "activo" ? "inactivo" : "activo"; guardar();
}
function borrarBarbero(id) {
  if (db.citas.some(c => c.id_barbero === id)) return alert("El barbero tiene citas registradas.");
  db.barberos = db.barberos.filter(b => b.id !== id); guardar();
}
function vistaBarberos() {
  return `<div class="caja"><h3>Registrar barbero</h3><div class="form">
    <input id="b_nombre" placeholder="Nombre"><input id="b_esp" placeholder="Especialidad">
    <button onclick="agregarBarbero()">Registrar barbero</button></div></div>` +
    tabla(["ID", "Nombre", "Especialidad", "Estado", "Acciones"],
      db.barberos.map(b => [b.id, b.nombre, b.especialidad, b.estado,
        `<button onclick="cambiarEstadoBarbero(${b.id})">Activar / desactivar</button><button onclick="borrarBarbero(${b.id})">Eliminar</button>`]));
}

// ---------- Servicios ----------
function agregarServicio() {
  db.servicios.push({ id: nuevoId(db.servicios), nombre: val("s_nombre"), duracion: Number(val("s_dur")), precio: Number(val("s_precio")) });
  guardar();
}
function borrarServicio(id) {
  if (db.citas.some(c => c.id_servicio === id)) return alert("El servicio está en uso en citas.");
  db.servicios = db.servicios.filter(s => s.id !== id); guardar();
}
function vistaServicios() {
  return `<div class="caja"><h3>Registrar servicio</h3><div class="form">
    <input id="s_nombre" placeholder="Nombre"><input id="s_dur" type="number" placeholder="Duración (min)">
    <input id="s_precio" type="number" placeholder="Precio (S/)">
    <button onclick="agregarServicio()">Registrar servicio</button></div></div>` +
    tabla(["ID", "Servicio", "Duración", "Precio", "Acciones"],
      db.servicios.map(s => [s.id, s.nombre, s.duracion + " min", "S/ " + s.precio,
        `<button onclick="borrarServicio(${s.id})">Eliminar</button>`]));
}

// ---------- Citas ----------
function agregarCita() {
  db.citas.push({ id: nuevoId(db.citas), id_cliente: Number(val("ci_cliente")), id_barbero: Number(val("ci_barbero")),
    id_servicio: Number(val("ci_servicio")), fecha_hora: val("ci_fecha"), estado: "pendiente" });
  guardar();
}
function cambiarEstado(id, estado) { get(db.citas, id).estado = estado; guardar(); }

function vistaCitas() {
  let h = "";
  if (esAdmin()) h += `<div class="caja"><h3>Registrar cita</h3><div class="form">
    <select id="ci_cliente">${opts(db.clientes, c => c.nombre + " " + c.apellido)}</select>
    <select id="ci_barbero">${opts(db.barberos.filter(b => b.estado === "activo"), b => b.nombre)}</select>
    <select id="ci_servicio">${opts(db.servicios, s => s.nombre + " - S/ " + s.precio)}</select>
    <input id="ci_fecha" type="datetime-local" value="2026-10-22T10:00">
    <button onclick="agregarCita()">Registrar cita</button></div></div>`;
  else h += `<p>Agenda de: <b>${get(db.barberos, idBarberoRol()).nombre}</b></p>`;
  let lista = [...db.citas].sort((a, b) => a.fecha_hora.localeCompare(b.fecha_hora));
  if (!esAdmin()) lista = lista.filter(c => c.id_barbero === idBarberoRol());
  h += tabla(["ID", "Fecha y hora", "Cliente", "Barbero", "Servicio", "Estado", "Cambiar estado"],
    lista.map(c => [c.id, fmt(c.fecha_hora), nombreCliente(c.id_cliente), get(db.barberos, c.id_barbero).nombre,
      get(db.servicios, c.id_servicio).nombre, c.estado,
      ESTADOS.filter(e => e !== c.estado).map(e => `<button onclick="cambiarEstado(${c.id},'${e}')">${e}</button>`).join("")]));
  return h;
}

// ---------- Pagos ----------
function citasPagables() {
  return db.citas.filter(c => c.estado !== "cancelada" && !db.pagos.some(p => p.id_cita === c.id));
}
function autoMonto() {
  const c = get(db.citas, val("p_cita")); if (c) document.getElementById("p_monto").value = get(db.servicios, c.id_servicio).precio;
}
function registrarPago() {
  if (!val("p_cita")) return alert("No hay citas pendientes de pago.");
  db.pagos.push({ id: nuevoId(db.pagos), id_cita: Number(val("p_cita")), monto: Number(val("p_monto")),
    metodo_pago: val("p_metodo"), fecha_pago: new Date().toISOString().slice(0, 16).replace("T", " ") });
  guardar();
}
function vistaPagos() {
  const pag = citasPagables();
  const montoIni = pag.length ? get(db.servicios, pag[0].id_servicio).precio : 0;
  const total = db.pagos.reduce((s, p) => s + p.monto, 0);
  return `<div class="caja"><h3>Registrar pago</h3><div class="form">
    <select id="p_cita" onchange="autoMonto()">${opts(pag, c => `Cita ${c.id} - ${nombreCliente(c.id_cliente)} - ${get(db.servicios, c.id_servicio).nombre}`)}</select>
    <input id="p_monto" type="number" value="${montoIni}">
    <select id="p_metodo">${METODOS.map(m => `<option>${m}</option>`).join("")}</select>
    <button onclick="registrarPago()">Pagar</button></div></div>` +
    tabla(["ID", "Cita", "Cliente", "Monto", "Método", "Fecha de pago"],
      db.pagos.map(p => { const c = get(db.citas, p.id_cita);
        return [p.id, p.id_cita, nombreCliente(c.id_cliente), "S/ " + p.monto, p.metodo_pago, p.fecha_pago]; })) +
    `<p><b>Total recaudado: S/ ${total}</b></p>`;
}

// ---------- render ----------
function render() {
  const r = document.getElementById("rol");
  r.innerHTML = `<option value="admin">Administrador</option>` +
    db.barberos.map(b => `<option value="b${b.id}">Barbero: ${b.nombre}</option>`).join("");
  r.value = rol;
  document.getElementById("menu").innerHTML =
    tabs().map(t => `<button class="${t === tab ? "activo" : ""}" onclick="irA('${t}')">${t}</button>`).join("");
  const vistas = { Clientes: vistaClientes, Barberos: vistaBarberos, Servicios: vistaServicios, Citas: vistaCitas, Pagos: vistaPagos };
  document.getElementById("contenido").innerHTML = "<h2>" + tab + "</h2>" + vistas[tab]();
}
render();
