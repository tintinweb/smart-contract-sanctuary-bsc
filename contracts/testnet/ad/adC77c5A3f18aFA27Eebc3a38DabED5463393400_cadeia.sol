/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract cadeia {
 
 event EmissaoPedidoFornecedor1 (address Fornecedor1, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3);
 event DespachoPedidoFornecedor1 (int16 NSU1, int16 Quantidade1, int16 Lote1, int16 NSU2, int16 Quantidade2, int16 Lote2, int16 NSU3, int16 Quantidade3, int16 Lote3);
 event EmitirNotaFornecedor1 (address Operador, int16 NSU1, int16 Quantidade1, int16 Preco1, int16 NSU2, int16 Quantidade2, int16 Preco2, int16 NSU3, int16 Quantidade3, int16 Preco3);
 event EmissaoPedidoFornecedor2 (address Fornecedor2, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC);
 event DespachoPedidoFornecedor2 (int16 NSUA, int16 QuantidadeA, int16 LoteA, int16 NSUB, int16 QuantidadeB, int16 LoteB, int16 NSUC, int16 QuantidadeC, int16 LoteC);
 event EmitirNotaFornecedor2 (address Operador, int16 NSUA, int16 QuantidadeA, int16 PrecoA,int16 NSUB, int16 QuantidadeB, int16 PrecoB, int16 NSUC, int16 QuantidadeC, int16 PrecoC); 
 event ReceberProdutoProdutor(string hash);
 event ReceberNotaProdutor (address Fornecedor1, address Fornecedor2, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC);
 event FabricarProdutor (address Operador, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC); 
 event ProducaoProduto1Produtor (string Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B);
 event ProducaoProduto2Produtor (string Produto2, int16 R, int16 Quantidade3AC, int16 Preco3AC);
 event DespachoPedidoProdutor1 (string Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B);
 event DespachoPedidoProdutor2 (string Produto2, address Distribuidor, int16 R, int16 Quantidade3AC, int16 Preco3AC);

 event EmitirNotaProdutor1 (string Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B);
 event EmitirNotaProdutor2 (string Produto2, address Distribuidor, int16 R, int16 Quantidade3AC, int16 Preco3AC);
 event ReceberProdutoDistribuidor (string hash); event ReceberNotaDistribuidor (address Operador, address Fornecedor1, address Fornecedor2, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC);
 event DespachoPedidoDistribuidor (int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC); 
 event EmitirNotaDistribuidor (address Distribuidor, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC); 
 event ReceberProdutoCliente1 (string hash);
 event ReceberNotaCliente1 (int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3);
 
 struct DefBasicas1 {int16 NSU1; int16 Quantidade1; int16 Preco1; int16 Peso1; int16 Lote1; int16 Turno1;}

 struct DefBasicas2 {int16 NSU2; int16 Quantidade2; int16 Preco2; int16 Peso2; int16 Lote2; int16 Turno2;}

 struct DefBasicas3 {int16 NSU3; int16 Quantidade3; int16 Preco3; int16 Peso3; int16 Lote3; int16 Turno3;}

 struct DefBasicasA {int16 NSUA; int16 QuantidadeA; int16 PrecoA; int16 PesoA; int16 LoteA; int16 TurnoA;}

 struct DefBasicasB {int16 NSUB; int16 QuantidadeB; int16 PrecoB; int16 PesoB; int16 LoteB; int16 TurnoB;}

 struct DefBasicasC {int16 NSUC; int16 QuantidadeC; int16 PrecoC; int16 PesoC; int16 LoteC; int16 TurnoC;} 

 struct NSU123ABC {int16 NSU1; int16 NSU2; int16 NSU3; int16 NSUA; int16 NSUB; int16 NSUC;}

 struct NSU123ABCrecebido {int16 NSU1_recebido; int16 NSU2_recebido; int16 NSU3_recebido; int16 NSUA_recebido; int16 NSUB_recebido; int16 NSUC_recebido;}
 
 struct S { uint16 NSU1; uint16 NSU2; uint16 NSUB;}
 int16 x;
 mapping(uint16 => mapping(uint16 => S)) data1; 
 struct R { uint16 NSU3; uint16 NSUA; uint16 NSUC;}
 int16 y;
 mapping(uint16 => mapping(uint16 => R)) data2; 

 
  function APedidoFornecedor1 (address Fornecedor1, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3) public { 
  emit EmissaoPedidoFornecedor1 (Fornecedor1, DefBasicas1, DefBasicas2, DefBasicas3);}


  function BPedidoFornecedor2 (address Fornecedor2, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public {
  emit EmissaoPedidoFornecedor2 (Fornecedor2, DefBasicasA, DefBasicasB, DefBasicasC);}
  
  
  function CDespachoFornecedor1 (int16 NSU1, int16 Quantidade1, int16 Lote1, int16 NSU2, int16 Quantidade2, int16 Lote2, int16 NSU3, int16 Quantidade3, int16 Lote3) public {
  emit DespachoPedidoFornecedor1 (NSU1, Quantidade1, Lote1, NSU2, Quantidade2, Lote2, NSU3, Quantidade3, Lote3);} 
  
  function DDespachoFornecedor2 (int16 NSUA, int16 QuantidadeA, int16 LoteA, int16 NSUB, int16 QuantidadeB, int16 LoteB, int16 NSUC, int16 QuantidadeC, int16 LoteC) public {
  emit DespachoPedidoFornecedor2 (NSUA, QuantidadeA, LoteA, NSUB, QuantidadeB, LoteB, NSUC, QuantidadeC, LoteC);} 
  
  function ENotaFornecedor1 (address Operador,int16 NSU1, int16 Quantidade1, int16 Preco1, int16 NSU2, int16 Quantidade2, int16 Preco2, int16 NSU3, int16 Quantidade3, int16 Preco3) public {
  emit EmitirNotaFornecedor1 (Operador, NSU1, Quantidade1, Preco1, NSU2, Quantidade2, Preco2, NSU3, Quantidade3, Preco3);}
  
  function FNotaFornecedor2 (address Operador, int16 NSUA, int16 QuantidadeA, int16 PrecoA,int16 NSUB, int16 QuantidadeB, int16 PrecoB, int16 NSUC, int16 QuantidadeC, int16 PrecoC) public {
  emit EmitirNotaFornecedor2 (Operador, NSUA, QuantidadeA, PrecoA, NSUB, QuantidadeB, PrecoB, NSUC, QuantidadeC, PrecoC);}

  function GReceberProdutoProd (string memory hash,int16 NSU123ABC, int16 NSU123ABCrecebido) public { 
  emit ReceberProdutoProdutor (hash);  assert (NSU123ABCrecebido==NSU123ABC);}
  
  function HReceberNotaProd (address Fornecedor1, address Fornecedor2, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public {
  emit ReceberNotaProdutor (Fornecedor1, Fornecedor2, DefBasicas1, DefBasicas2, DefBasicas3, DefBasicasA, DefBasicasB, DefBasicasC);}
  
  function IFabricarProd (address Operador, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public { 
  emit FabricarProdutor (Operador, DefBasicas1, DefBasicas2, DefBasicas3, DefBasicasA, DefBasicasB, DefBasicasC);}

  function JProducaoProduto1Prod (string memory Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B) public {
  emit ProducaoProduto1Produtor (Produto1, Distribuidor, S, Quantidade12B, Preco12B);}

  function KProducaoProduto2Prod (string memory Produto2, int16 R, int16 Quantidade3AC, int16 Preco3AC) public { 
  emit ProducaoProduto2Produtor (Produto2, R, Quantidade3AC, Preco3AC);}

  function LDespachoPedidoProd1 (string memory Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B) public {
  emit DespachoPedidoProdutor1 (Produto1, Distribuidor, S, Quantidade12B, Preco12B);}

  function MDespachoPedidoProd2 (string memory Produto2, address Distribuidor, int16 R, int16 Quantidade3AC, int16 Preco3AC) public {
  emit DespachoPedidoProdutor1 (Produto2, Distribuidor, R, Quantidade3AC, Preco3AC);}

  function NEmitirNotaProd1 (string memory Produto1, address Distribuidor, int16 S, int16 Quantidade12B, int16 Preco12B) public {
  emit EmitirNotaProdutor1 (Produto1, Distribuidor, S, Quantidade12B, Preco12B);}
  
  function OEmitirNotaProd2 (string memory Produto2, address Distribuidor, int16 R, int16 Quantidade3AC, int16 Preco3AC) public {
  emit EmitirNotaProdutor2 (Produto2, Distribuidor, R, Quantidade3AC, Preco3AC);}
  
  function PReceberProdutoDist (string memory hash, int16 NSU123ABC, int16 NSU123ABCrecebido) public { emit ReceberProdutoDistribuidor (hash);
  assert (NSU123ABCrecebido==NSU123ABC);}

  function QReceberNotaDist (address Operador, address Fornecedor1, address Fornecedor2, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public {
  emit ReceberNotaDistribuidor (Operador, Fornecedor1, Fornecedor2, DefBasicas1, DefBasicas2, DefBasicas3, DefBasicasA, DefBasicasB, DefBasicasC);}


  function RDespachoPedidoDist (int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public {
  emit DespachoPedidoDistribuidor (DefBasicas1, DefBasicas2, DefBasicas3, DefBasicasA, DefBasicasB, DefBasicasC);}
  
  function SEmitirNotaDist (address Distribuidor, int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3, int16 DefBasicasA, int16 DefBasicasB, int16 DefBasicasC) public {
  emit EmitirNotaDistribuidor (Distribuidor, DefBasicas1, DefBasicas2, DefBasicas3, DefBasicasA, DefBasicasB, DefBasicasC);}

  function TReceberProdutoClien1 (string memory hash, int16 NSU123ABC, int16 NSU123ABCrecebido) public { 
  emit ReceberProdutoCliente1 (hash); assert (NSU123ABCrecebido==NSU123ABC);} 
  function UReceberNotaClien1 (int16 DefBasicas1, int16 DefBasicas2, int16 DefBasicas3) public { 
  emit ReceberNotaCliente1 ( DefBasicas1, DefBasicas2, DefBasicas3);}
  

}