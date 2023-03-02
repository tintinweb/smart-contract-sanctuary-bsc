/**
 *Submitted for verification at BscScan.com on 2023-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract IDO {
    //用户信息

    mapping(address => User) public getUser;

    bool reEntrancyMutex = false;

    address tokenAddress;
    address owner;
    address payable funder1;
    address payable funder2;

    IERC20 BDC;
    uint constant ONE_BNB = 10 ** 18;

    struct User {
        address superior;
        address granSuperior;
        uint balance;
        uint earnedBNB;
        uint inviterNum;
    } 

    modifier onlyOwner(){
        require(msg.sender == owner,"not owner");
        _;
    }

    constructor(address payable _funder1, address payable _funder2,address _tokenAddress){
        owner = msg.sender;
        funder1 = _funder1;
        funder2 = _funder2;
        BDC = IERC20(_tokenAddress);
    }

    function update(address user, uint BNBAmount) private {
        getUser[user].earnedBNB += BNBAmount;
        
    }

    function updateNum(address user) private {
        getUser[user].inviterNum ++;
        
    }


    function setTokenAddress(address _tokenAddress) public onlyOwner{
        tokenAddress = _tokenAddress;
        BDC = IERC20(_tokenAddress);
        
    }

//已经有上级的

    function fundHadSuperior_02_BNB() public payable{

        address user = msg.sender;
        address payable superior = payable (getUser[user].superior);
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/5,"require 0.2 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior != address(0), "you no had superior");



        getUser[user].balance += amount;

        superior.transfer(superiorAmount);//给10%
        update(superior, superiorAmount);


        //如果有上上级
        if(getUser[superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user,2 * ONE_BNB);

        reEntrancyMutex = false;
    }

    function fundHadSuperior_05_BNB() public payable{

        address user = msg.sender;
        address payable superior = payable (getUser[user].superior);
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/2,"require 0.5 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior != address(0), "you no had superior");



        getUser[user].balance += amount;

        superior.transfer(superiorAmount);//给10%
        update(superior, superiorAmount);


        //如果有上上级
        if(getUser[superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user,5 * ONE_BNB);

        reEntrancyMutex = false;
    }

    function fundHadSuperior_1_BNB() public payable{

        address user = msg.sender;
        address payable superior = payable (getUser[user].superior);
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB,"require 1 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior != address(0), "you no had superior");



        getUser[user].balance += amount;

        superior.transfer(superiorAmount);//给10%
        update(superior, superiorAmount);


        //如果有上上级
        if(getUser[superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            


        }

        else {          
            address payable granSuperior = payable ( getUser[superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user,10 * ONE_BNB);

        reEntrancyMutex = false;
    }

    function fundHadSuperior_01_BNB() public payable{

        address user = msg.sender;
        address payable superior = payable (getUser[user].superior);
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/10,"require 0.1 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior != address(0), "you no had superior");



        getUser[user].balance += amount;

        superior.transfer(superiorAmount);//给10%
        update(superior, superiorAmount);

        //如果有上上级
        if(getUser[superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            


        }

        else {          
            address payable granSuperior = payable ( getUser[superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user,ONE_BNB);

        reEntrancyMutex = false;
    }


    //0.1BNB
    function fundWith_01_BNB(address payable _superior) public payable{
        address user = msg.sender;
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/10,"require 0.1 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior == address(0), "you had superior");

        require( _superior != address(0), "superior == 0");

        getUser[user].superior = _superior;
        getUser[user].balance += amount;

        _superior.transfer(superiorAmount);//给10%
        update(_superior, superiorAmount);
        updateNum(_superior);


        //如果有上上级
        if(getUser[_superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[_superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user, 2 * ONE_BNB);

        reEntrancyMutex = false;
    }


    function fundWith_02_BNB(address payable _superior) public payable{
        address user = msg.sender;
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/5,"require 0.2 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior == address(0), "you had superior");

        require( _superior != address(0), "superior == 0");

        getUser[user].superior = _superior;
        getUser[user].balance += amount;

        _superior.transfer(superiorAmount);//给10%
        update(_superior, superiorAmount);
        updateNum(_superior);


        //如果有上上级
        if(getUser[_superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[_superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user, 2 * ONE_BNB);

        reEntrancyMutex = false;
    }

        function fundWith_05_BNB(address payable _superior) public payable{
        address user = msg.sender;
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB/2,"require 0.5 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior == address(0), "you had superior");

        require( _superior != address(0), "superior == 0");

        getUser[user].superior = _superior;
        getUser[user].balance += amount;

        _superior.transfer(superiorAmount);//给10%
        update(_superior, superiorAmount);
        updateNum(_superior);


        //如果有上上级
        if(getUser[_superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[_superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user, 5 * ONE_BNB);

        reEntrancyMutex = false;
    }

        function fundWith_1_BNB(address payable _superior) public payable{
        address user = msg.sender;
        uint amount = msg.value;

        uint superiorAmount = amount/10;
        uint granSuperiorAmount = amount/50;
        uint fundAmount = (amount - superiorAmount -granSuperiorAmount)/2;

        require(!reEntrancyMutex,"reEntrancyMutex");//防止黑客
        reEntrancyMutex = true;

        require(msg.value == ONE_BNB,"require 1 BNB"); 
        require(getUser[user].balance < ONE_BNB , "every user max ido is 1 bnb");

        require(getUser[user].superior == address(0), "you had superior");

        require( _superior != address(0), "superior == 0");

        getUser[user].superior = _superior;
        getUser[user].balance += amount;

        _superior.transfer(superiorAmount);//给10%
        update(_superior, superiorAmount);
        updateNum(_superior);


        //如果有上上级
        if(getUser[_superior].superior != address(0))
        {
            fundAmount = (amount - superiorAmount)/2;
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);


        }

        else {          
            address payable granSuperior = payable ( getUser[_superior].superior);
            getUser[user].granSuperior = granSuperior;
            granSuperior.transfer(granSuperiorAmount);//给2%
            funder1.transfer(fundAmount);
            funder2.transfer(fundAmount);
            update(granSuperior, granSuperiorAmount);

        }

        BDC.transfer(user, 10 * ONE_BNB);

        reEntrancyMutex = false;
    }

 


    function getBalanceOfContract() public view returns(uint){
        return BDC.balanceOf(address(this));       
    }

    function getUserDataByStruct(address _user) public view returns(User memory){
        return getUser[_user];
    }
    //邀请码，推广人数，奖励，余额

    function getUserData(address _user) public view returns(address,uint, uint, uint ){
        address user = _user;
        uint inviterNum = getUser[user].inviterNum;
        uint earned = getUser[user].earnedBNB;
        uint balance = BDC.balanceOf(user);

        return  (user,inviterNum,earned,balance);
    }



    function withdrawBDC() public onlyOwner{
        BDC.transfer(msg.sender, getBalanceOfContract());
        
    }



    function withdrawBNB() external onlyOwner{
        address payable user = payable(msg.sender);
        user.transfer((address(this)).balance);
    }





    //IDO

    //
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}