/**
 *Submitted for verification at BscScan.com on 2023-02-13
*/

// SPDX-License-Identifier: GPL-3.0
 pragma solidity ^0.8.0;
contract CadeiaSuprimentos {
  //listo paso 0 registro de informacion del agricultor-- prodext servirá para colocar la referencia en caso la produccion vaya al laboratorio
  struct FornecedoreS {string CodigoProdutoAgricolaS; string CodFornecedorS; int NumeroloteColetadoS; int quantidadeS; int precoagricolaS; string ProdExtS;}
  FornecedoreS[] public fornecedores; 
  event ProduccionAgricolaAgricultor (address indexed to, address indexed from, string _CodigoProductoAgricola, string _CodFornecedor,int _NumLoteColectado, int _quantidade, int _precoAgricola, string _ProdExt);
  function ProducionAgricola (address to, address from, string memory _CodigoProductoAgricola, string memory _CodFornecedor, int _NumLoteColectado, int _quantidade, int _precoAgricola, string memory _ProdExt) public {
  uint timestamp;
  timestamp = block.timestamp;
  FornecedoreS memory novofornecedor;
  novofornecedor.CodigoProdutoAgricolaS = _CodigoProductoAgricola;
  novofornecedor.CodFornecedorS = _CodFornecedor;
  novofornecedor.NumeroloteColetadoS = _NumLoteColectado;
  novofornecedor.quantidadeS = _quantidade;
  novofornecedor.precoagricolaS = _precoAgricola;
  novofornecedor.ProdExtS = _ProdExt;
  fornecedores.push(novofornecedor);
  emit ProduccionAgricolaAgricultor (to, from, _CodigoProductoAgricola, _CodFornecedor ,_NumLoteColectado, _quantidade, _precoAgricola, _ProdExt);}
 
 // para el paso 1 el agricultor solicita el analisis de la produccion y codigo de autorizacion de produccion "campo certificado" 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2 = endereço do agricultor para solicitar analisis
  struct AvalSolCriteriosMostra {int CodigoSolicitudAvaliacao; int IDMostra;}
  AvalSolCriteriosMostra[] public AvalSolCriteriosMostraS;
  event SolicitudAvaliaMostra (address indexed to1, address indexed from2, int _CodsolicitudAnls,int _CodigMostra, string _hash1);
  function SolicAvalMostra(address to1, address from2, int _CodsolicitudAnls, int _CodigMostra, string memory _hash1) public {
  require(msg.sender==0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
  uint timestamp;
  timestamp = block.timestamp;
  AvalSolCriteriosMostra memory novoAvalSolCriteriosMostraS;
  novoAvalSolCriteriosMostraS.CodigoSolicitudAvaliacao = _CodsolicitudAnls;
  novoAvalSolCriteriosMostraS.IDMostra = _CodigMostra;
  AvalSolCriteriosMostraS.push(novoAvalSolCriteriosMostraS);
  emit SolicitudAvaliaMostra(to1, from2, _CodsolicitudAnls, _CodigMostra,_hash1);}
  // deberia tener el address fornecedor porque como fornecedor estaré enviando la solicitud lo cual me permite hacer la transaccion
  //y colocar el  hash de la transaccion que hizo en el registro de la produccion en el paso 0; hash1 = ejecucion de la funcion 0

 // paso 2resultado de analisis del laboratorio para confirmar que la carga esta en condiciones optimas dirigido a esa visibilidad

  /*event AsignarResultado (address Cliente, string _condicion, uint codigoLabo);
  mapping(string => uint) ResultadodeAvaliacao;
  address public owner = msg.sender;
  function AsigResultado(address Cliente, string memory _condicion, uint codigoLabo) public {
    require(msg.sender==owner);
    ResultadodeAvaliacao[_condicion] = codigoLabo;
  emit AsignarResultado(Cliente, _condicion, codigoLabo);}*/ // primera idea asi que no debemos olvidar esto
  struct ResultadoAnalsLab {string ResultadoSLab; int CodigoSolicitudAvaliacaoS; string LabIDs; string TemperaturaS; string InsumQuimicoS; string CalidadAguaS;}
  ResultadoAnalsLab [] public ResultadosAnalisisLab;
  event ResultadoLab (address indexed to3, address indexed from3, string _ResultadoAval, int _CodsolicitudAnls, string _LabID, string _Temperatura, string _InsumQuimico, string _CalidadAgua, string _hash1);
  function ResultadoLabO (address to3, address from3, string memory _ResultadoAval, int _CodsolicitudAnls, string memory _LabID, string memory _Temperatura, string memory _InsumQuimico, string memory _CalidadAgua, string memory _hash1) public {
  require(msg.sender==0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
  uint timestamp;
  timestamp = block.timestamp;
  ResultadoAnalsLab memory NovoResultadLab;
  NovoResultadLab.ResultadoSLab = _ResultadoAval;
  NovoResultadLab.CodigoSolicitudAvaliacaoS = _CodsolicitudAnls;
  NovoResultadLab.LabIDs = _LabID;
  NovoResultadLab.TemperaturaS = _Temperatura;
  NovoResultadLab.InsumQuimicoS = _InsumQuimico;
  NovoResultadLab.CalidadAguaS = _CalidadAgua;
  ResultadosAnalisisLab.push(NovoResultadLab);
  emit ResultadoLab(to3, from3, _ResultadoAval, _CodsolicitudAnls, _LabID, _Temperatura, _InsumQuimico, _CalidadAgua, _hash1);}
  
// EMPEZAMOS CON LA PARTE TRANSFORMADORA

  //passo 1
  //requerimiento del transformador hacia el productor agricola, luego de que este ultimo tenga el ok del laboratorio, asi puede continuar con el flujo.

  // me parece que debo crear una estructura para todos los requerimientos que la empresa necesite solicitar eso incluye pedido1, 2, 3, 4.
 // hash 2 es el resultado del codigo de aprovacion o desaprobacion de la frruta en el paso anterior
 // con este paso deberiamos generar muchas orden de pedidos de acuerdo con la estructura, estos pedidos seran colocados por la transformadora 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

  struct PedidosS {string ProdExtS; int NRequerimentO; int QuantidadE; int PrecO; int PesO; int LotE; string IDPEDIDO; string hash2;}
  PedidosS[] public Requerimentos; 
  event OrdenRequerimientoEmpresa1 (address indexed to4, address indexed from4, string _ProdExtS, int _Nrequerimiento, int _quantidadeRequerida1, int _preco, int _peso, int _Lote1, string _condicion, string _IDPEDIDO, string _hash2);
  function OrdenRequerEMpresa1 (address to4, address from4, string memory _ProdExtS, int _Nrequerimiento, int _quantidadeRequerida1, int _preco, int _peso, int _Lote1, string memory _condicion, string memory _IDPEDIDO, string memory _hash2) public{
  uint timestamp;
  timestamp = block.timestamp;
  require(msg.sender==0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
  PedidosS memory novoRequerimento;
  novoRequerimento.ProdExtS = _ProdExtS;
  novoRequerimento.NRequerimentO = _Nrequerimiento;
  novoRequerimento.QuantidadE = _quantidadeRequerida1;
  novoRequerimento.PrecO = _preco;
  novoRequerimento.PesO = _peso;
  novoRequerimento.LotE = _Lote1;
  novoRequerimento.IDPEDIDO = _IDPEDIDO;
  novoRequerimento.hash2 = _hash2;
  Requerimentos.push(novoRequerimento);
  emit OrdenRequerimientoEmpresa1 (to4, from4, _ProdExtS, _Nrequerimiento, _quantidadeRequerida1, _preco, _peso, _Lote1, _condicion, _IDPEDIDO, _hash2);}

  //emision de nota y detalle y Unidad de transporte a entregar a la empresa1 (la que solicita el servicio) agricultor a empresa
  //paso 2
  //confirmacion de la emsision de guia con el hash 3, este ultimo es el consolidado del pedido// adenmáss de ello se adicionaran mas datos //fornecedor=agricultor
  struct GuiaS {int NumGuiaS; string TransportadoraS; string Hash3;}
  GuiaS[] public guiasEmis;
  event EmnisionGuiaVenta1 (string _hash3, int _NumguiaVenta, string _transportadora);
  function EmisiGuiaVenta1 (string memory _hash3, int _NumguiaVenta, string memory _transportadora) public {
  require(msg.sender==0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
  GuiaS memory novaguiasEmis;
  novaguiasEmis.NumGuiaS = _NumguiaVenta;
  novaguiasEmis.TransportadoraS = _transportadora;
  novaguiasEmis.Hash3 = _hash3;
  guiasEmis.push(novaguiasEmis);
  emit EmnisionGuiaVenta1 ( _hash3, _NumguiaVenta, _transportadora);}
  
  //ahora se tendria que hacer el despacho de las unidades confirmadas en la guiaventa (hash4) 
  //paso 3 realizar el despacho con hash4
  event GDespachoPedidoAgrifornecedor1 (string _hash4, int _HoraArribo);
  function DespachoPedidoAgrifornecedor1 (string memory _hash4, int _HoraArribo) public {
  //require(msg.sender==0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
  uint timestamp;
  timestamp = block.timestamp;
  emit GDespachoPedidoAgrifornecedor1 (_hash4, _HoraArribo);}

  //deberia haber una funcion para solicitar a senasa un ing.
  struct SolicitudIngSenasaS {string ProductodeExportacionS; int DiaMesAnoS; int HoraS; string lugarS; string Hash3;}
  SolicitudIngSenasaS[] public SolicitudIngSenasa;
  event SolicIngSenasa (address indexed to5, address indexed from5, string _ProductoDeExportacion, int _DiaMesAno, int _hora, string _Lugar, string _hash3);
  function SolicIngeSenasa (address to5, address from5, string memory _ProductoDeExportacion, int _DiaMesAno, int _hora, string memory _Lugar, string memory _hash3) public {
  uint timestamp;
  timestamp = block.timestamp;
  require(msg.sender==0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
  SolicitudIngSenasaS memory novoSolicitudIngSenasa;
  novoSolicitudIngSenasa.ProductodeExportacionS = _ProductoDeExportacion;
  novoSolicitudIngSenasa.DiaMesAnoS = _DiaMesAno;
  novoSolicitudIngSenasa.HoraS = _hora;
  novoSolicitudIngSenasa.lugarS = _Lugar;
  novoSolicitudIngSenasa.Hash3 = _hash3;
  SolicitudIngSenasa.push(novoSolicitudIngSenasa);
  emit SolicIngSenasa(to5, from5, _ProductoDeExportacion, _DiaMesAno, _hora, _Lugar, _hash3);}


  //aqui debe entrar la funcion para la certificacion de senasa o de alguna entidad
  struct OrigenCertificadoS {string ProductoSenasAS; int CodigosCertificadoS; string Hash2; int CodigoIngSenasaS; int FechaInspeccion; string LugardeCargaS; string StatusFinalS;}
  event ValidacionCertificadoEstatal (address indexed to6, address indexed from6, string _ProductoSenasa, int _CodigoCertificado, string _referenciaHash2, int _CodigoIngSenasa, int _fechaInspeccion, string _LugardeCarga, string _StatusFInal);
  OrigenCertificadoS [] public OrigenCertificadosSenasa;
  function CertificacionEmpresaEstatal (address to6, address from6, string memory _ProductoSenasa, int _CodigoCertificado, string memory _referenciaHash2, int _CodigoIngSenasa, int _fechaInspeccion, string memory _LugardeCarga, string memory _StatusFInal) public {
  require(msg.sender==0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
  uint timestamp;
  timestamp = block.timestamp;
  OrigenCertificadoS memory novoOrigenCertificadosSenasa;
  novoOrigenCertificadosSenasa.ProductoSenasAS = _ProductoSenasa;
  novoOrigenCertificadosSenasa.CodigosCertificadoS = _CodigoCertificado;
  novoOrigenCertificadosSenasa.Hash2 = _referenciaHash2;
  novoOrigenCertificadosSenasa.CodigoIngSenasaS = _CodigoIngSenasa;
  novoOrigenCertificadosSenasa.FechaInspeccion = _fechaInspeccion;
  novoOrigenCertificadosSenasa.LugardeCargaS = _LugardeCarga;
  novoOrigenCertificadosSenasa.StatusFinalS = _StatusFInal;
  OrigenCertificadosSenasa.push(novoOrigenCertificadosSenasa);
  emit ValidacionCertificadoEstatal (to6, from6, _ProductoSenasa, _CodigoCertificado, _referenciaHash2, _CodigoIngSenasa, _fechaInspeccion, _LugardeCarga, _StatusFInal);
  }

 // ahora recepcion de la mercaderia por  parte de la empresa1 (procesador) , agrifornecedor (agricultor)

  //function RecepcionOrdenCompraProce ( address AgriFornecedor1, address Empresa1, uint quantidadeRequerida1, uint Lote1, string _condicion, uint codigoLabo, string _transportadora,uint _horasalidaA, uint _horaIngresoE)
 
 /*function ConsultaCliente (uint id) external view returns (string memory, int, int, int) {
 FornecedoreS memory consultaS = fornecedores[id];
 AvalSolCriteriosMostra memory consultaSS = AvalSolCriteriosMostraS[id];
 return ( consultaS.CodFornecedorS, consultaS.NumeroloteColetadoS, consultaS.precoagricolaS, consultaSS.CodigoSolicitudAvaliacao);
 }*/

}