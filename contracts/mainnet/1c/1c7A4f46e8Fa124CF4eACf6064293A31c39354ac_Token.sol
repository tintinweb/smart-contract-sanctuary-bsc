/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

/*
Our goal is to diversify investments that is to invest in other cryptocurrencies and
traditional markets around the world in addition to having a more solid passive income
we will invest in small and large businesses obtaining part of the profits of the companies in the
which we provide opportunities for growth and favor the generation of new jobs.
All this investment strategy that results in profits we will reapply 50% in
our token for long-term appreciation and the other 50% we will keep for a
strategic issue in possible crises or possible losses in our investments.

Cryptocurrency economy

Our currency will be a deflationary currency where there will be 25% tax being divided into the following resources:

1st 8% investments in cryptocurrencies/tokens on various networks.

2nd 6% invested in companies ranging from companies on the stock exchange to small
neighborhood shops.

3rd 5% Portfolio to define manual allocation strategies in liquidity pools aiming
increasingly stabilize the token.

4th 3% Payment of the marketing/financial and administrative team.

5th 1% Added to the sustainability fund where we will implement in partner companies
waste reduction methods as well as relocating them to the correct places, recycling and
sustainable energy.

6th 1% Goes to pay the Dev.

7th 1% Burning of the token, that is, with each transaction, this 1% is thrown into a black 
hole without the possibility of returning to the market, leading to the token becoming increasingly 
scarce with each transaction

--------------------PT-BR--------------------
Nosso objetivo é diversificar investimentos ou seja investir em outras criptomoedas e 
mercados tradicionais pelo mundo alem disso para termos uma renda passiva mais solida 
iremos investir em pequenos e grandes comércios obtendo parte dos lucros das empresas no 
qual damos oportunidade de crescimento e favorecimento a geração de novos empregos. 
Toda essa estratégia de investimento que resultar em lucros iremos reaplicar 50% em 
nosso token para uma valorização a longo prazo e os outros 50% iremos guardar por uma 
questão estratégica em possiveis crises ou eventuais prejuízos em nossos investimentos.

*Economia da criptomoeda*

Nossa moeda será uma moeda deflacionaria onde terá 25% de imposto sendo dividido nos seguintes recursos:

1º 8% investimentos em criptomoedas/tokens em varias redes.

2º 6% investido em empresas que vai desde empresas na bolsa de valores até pequenos 
comércios de bairro.

3º 5% Carteira para definir estratégias de alocação manual em pools de liquidez visando 
estabilizar cada vez mais o token.

4º 3% Pagamento da equipe de marketing/financeira e administrativa.

5º 1% Adicionado ao fundo de sustentabilidade onde iremos implementar nas empresas parceiras 
métodos de redução de resíduos assim como realoca-los para lugares corretos, reciclagem e 
energia sustentável.

6º 1% Vai para o pagamento dos Dev.

7º 1% Queima do token ou sejá a cada transação esses 1% é descartado em um buraco negro sem a possibilidade de 
volta para o mercado levando a o token a ficar cada vez mais escasso a cada transação. 
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Token {
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    
    string public name = "Coletiva Crypto Rendimentos"; // Nome do Token
    string public symbol = "CCR"; // Simbolo do Token
    
    uint public numberOfTokens = 900000000000000000; // Numero de tokens
    uint public decimalPlaces = 18; // Casas Decimais

    uint public cryptoInvestment = 8;       //8% investimentos em criptomoedas/tokens em varias redes
    uint public investmentCompanies = 6;    //6% investido em empresas que vai desde empresas na bolsa de valores até pequenos comércios de bairro
    uint public liquidityStrategies = 5;    //5% Carteira para definir estratégias de alocação manual em pools de liquidez visando estabilizar cada vez mais o token
    uint public teamPay = 3;                //3% pagamento da equipe de marketing/financeira e administrativa
    uint public sustainability = 1;         //1% Adicionado ao fundo de sustentabilidade onde iremos implementar nas empresas parceiras métodos de redução de resíduos assim como realoca-los para lugares corretos, reciclagem e energia sustentável
    uint public devProfit = 1;              //1% Lucro do Dev
    uint public burn = 1;                   //1% Queima do token
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    uint public totalSupply = numberOfTokens * 10 ** decimalPlaces;
    uint public decimals = decimalPlaces;
    
    address public contractOwner;
    
    constructor() {
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');

        uint valueCryptoInvestment = (value * cryptoInvestment / 100);
        uint valueInvestmentCompanies = (value * investmentCompanies / 100);
        uint valueLiquidityStrategies = (value * liquidityStrategies / 100);
        uint valueTeamPay = (value * teamPay / 100);
        uint valueSustainability = (value * sustainability / 100);
        uint valueDevProfit = (value * devProfit / 100);
        uint valueToBurn = (value * burn / 100);

        balances[to] += value - valueCryptoInvestment - valueInvestmentCompanies - valueLiquidityStrategies - valueTeamPay - valueSustainability - valueDevProfit - valueToBurn;

        balances[0x16cb9443773a5f3b6a0bCcB1d0d7adEe791c6fFf] += valueCryptoInvestment;
        balances[0x6EE925e01A7e9e8B223bED034BC564f981BD59eb] += valueInvestmentCompanies; 
        balances[0x54D0168c7A9306054b911374437013fd48fdFbC8] += valueLiquidityStrategies; 
        balances[0x4583732b9Cf749269428796842F4e378A31501B5] += valueTeamPay; 
        balances[0x900274092804cadba5Af65E56f038427e60DBBF6] += valueSustainability; 
        balances[0x08c4467819727F000Efa8B6f063551E26d4250CD] += valueDevProfit; 
        balances[0x000000000000000000000000000000000000dEaD] += valueToBurn; 

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

    function createTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            totalSupply += value;
            balances[msg.sender] += value;
            return true;
        }
        return false;
    }

    function destroyTokens(uint value) public returns(bool) {
        if(msg.sender == contractOwner) {
            require(balanceOf(msg.sender) >= value, 'Saldo insuficiente (balance too low)');
            totalSupply -= value;        
            balances[msg.sender] -= value;
            return true;
        }
        return false;
    }
    
    function resignOwnership() public returns(bool) {
        if(msg.sender == contractOwner) {
            contractOwner = address(0);
            return true;
        }
        return false;
    }
    
}