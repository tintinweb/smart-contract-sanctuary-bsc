/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract UnderWaterTreasure {
    
    mapping (address => uint) public balances;

    address constant public Egetesicim=0x000000000000000000000000000000000000dEaD; //A játék megvásárlásánál elégnek a tokenek

    mapping (address => mapping(address => uint)) public allowance;

    uint public TeljesKinalat=50000000*10**18; //A 10^18 azért kell, hogy a metamask teljes tokenként jelenítse meg. Máskülönben nagyon kicsi egységek lennének

    string public name = "Underwater Treasure";

    string public symbol = "UWT";

    uint public decimals=18;

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed  spender, uint value);

    //Property
    mapping (address => bool) PaymentWallet; //PaymentWallet jogosultság. Ő intézi a kifizetéseket a játékosoknak
    mapping (address => bool) Jatekos; //A PaymentWallet csak játékos részére intézhet kifizetéseket

    constructor(){
        balances[msg.sender]=TeljesKinalat;
        PaymentWallet[msg.sender]=true; //Az kapja meg a paymentwallet jogosultságot, aki deployolja a contractot.
    }

    function Jatekvasarlas() public{

        require((PaymentWallet[msg.sender])==false,"A kifizetesert felelos walletnek nem adhato Jatekos jogosultsag");

        require((Jatekos[msg.sender])==false,"Ez a wallet mar rendelkezik jatekos jogosultsaggal");

        require(balances[msg.sender]>=100*10**18,"Nincs eleg tokened a Jatekos rang megvasarlasahoz. A rang ara: 100 UWT token.");

       
            balances[msg.sender]-=100*10**18;

            Jatekos[msg.sender]=true;

            emit Transfer(msg.sender, Egetesicim, 100*10**18);
       

    }

    function balanceOf(address owner) public returns(uint) {
        return balances[owner];
    }
        
    function transfer(address to, uint value) public returns (bool){
        if((PaymentWallet[msg.sender])==false){

            require(balanceOf(msg.sender)>=value,"A tranzakciohoz nincs elegendo mennyisegu UWT tokened");

            balances[to]+=value;

            balances[msg.sender]-=value;

            emit Transfer(msg.sender, to, value);

            return true;
        }
        else{

            require((Jatekos[to])==true,"A celpenztarca nem rendelkezik jatekos jogosultsaggal.");

            value=(balances[msg.sender]/1000000000000000000)*(balances[to]/10000000000000);
            
        
            require(balanceOf(msg.sender)>=value,"A tranzakciohoz nincs elegendo mennyisegu UWT tokened");

            balances[msg.sender]-=value;

            balances[to]+=value;

            emit Transfer(msg.sender, to, value);

            return true;

        }
        return false;
    }

    function trasferFrom(address from, address to, uint value) public returns (bool){

        require(balanceOf(from)>=value,"A tranzakciohoz nincs elegendo mennyisegu UWT tokened");

        require(allowance[from][msg.sender]>=value,"Tul kicsi a juttatas");

        balances[from]-=value;

        balances[to]+=value;

        emit Transfer(from, to, value);

        return true;

    }

    function approve(address spender, uint value) public returns (bool){

        allowance[msg.sender][spender]=value;

        emit Approval(msg.sender, spender, value);

        return true;

    }
    

}