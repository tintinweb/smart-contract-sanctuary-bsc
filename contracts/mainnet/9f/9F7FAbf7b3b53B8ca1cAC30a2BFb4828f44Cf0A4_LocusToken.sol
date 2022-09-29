/**
 *Submitted for verification at BscScan.com on 2022-09-29
*/

// SPDX-License-Identifier: MIT

//Site:      http://locus.emp.br                                                 
//Telegram:  https://t.me/LocusToken 
//Instagram: https://www.instagram.com/locustoken
//Twitter:   https://twitter.com/LocusToken
//E-mail:    [email protected] 

//Taxas de compra e venda 9% com a seguinte distribuição: 
//3% queima automática, 
//6% para desenvolvimento do projeto, marketing e listagens. 

/*Locus Token, Projeto ligado Empresa física Locus Empreendimentos,
A proposta do projeto LOCUS Token é oferecer a oportunidade a qualquer 
pessoa em fazer parte de uma estrutura de desenvolvimento e 
empreendedorismo na área da educação digital, que tem se tornado, 
cada dia, tão importante para o desenvolvimento/evolução do ser humano. 
Até porque, a pandemia da Covid-19, deflagrou diversas realidades 
urgente e emergente, e muitas atividades rotineiras tiveram que se 
adaptar ao novo contexto, principalmente a área educacional que precisou 
adotar modelos remotos, intermediados por meio das Tecnologias da 
Informação e Comunicação – TICs. Portanto, investir em educação digital 
se tornou uma necessidade no aprimoramento de ferramentas e metodologias 
que ajudam alunos e professores, além de contribuir para o processo de 
ensino-aprendizagem. Além disso, nós acreditamos na evolução da economia 
por meio da tecnologia, entendemos o progresso dos ativos digitais na 
potencialização desse novo sistema financeiro descentralizado. Ao investir 
na moeda LOCUS, além dos ganhos que o titular tem com a valorização cambial 
que ocorre naturalmente com a entrada de novos investidores, o nosso 
investidor também contará com a valorização que o token ganhará, pois, 
20% do faturamento líquido mensal da empresa física Locus Empreendimentos 
será reinvestido diretamente na liquidez do projeto impactando na 
valorização do LOCUS Token e trazendo mais benefícios para os titulares 
do token. Outra importante funcionalidade no contrato inteligente 
do LOCUS Token é a função de queima, a cada transação 3% é queimado 
para sempre tornando o token deflacionário, enquanto menor o supply 
mais escasso fica o token, causando uma valorização imensa a médio 
e longo prazo em seu investimento..*/

pragma solidity ^0.8.2;

contract LocusToken {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    uint public totalSupply = 300000 * 10 ** 18;
    string public name = "Locus Token";
    string public symbol = "LOCUS";
    uint public decimals = 18;
    
    uint public burnRate = 9; //Queima automática 3% dos token e 6% transferidos para carteiras de desenvolvimento do projeto, marketing e listagens
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    address public adressMarketing = 0x5c372c9Fd17030CdeA588FAF4778A5b201B14E46;
    address public adressProject = 0x30c9342F877457044465146aDc0F7bC3DA29bb1d;
    address public adressBurn = 0x1111111111111111111111111111111111222222;

    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
        uint valueToBurn = (value * burnRate / 100);
        balances[to] += value - valueToBurn;
        balances[0x5c372c9Fd17030CdeA588FAF4778A5b201B14E46] += valueToBurn/3;
        balances[0x30c9342F877457044465146aDc0F7bC3DA29bb1d] += valueToBurn/3;
        balances[0x1111111111111111111111111111111111222222] += valueToBurn/3;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'Saldo insuficiente (balance too low)');
        require(allowance[from][msg.sender] >= value, 'Sem permissao (allowance too low)');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
}