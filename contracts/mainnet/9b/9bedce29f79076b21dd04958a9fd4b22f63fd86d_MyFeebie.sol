// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./SafeMath.sol";
import "./IUniswapV2Router02.sol";

interface IBEP20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address _owner)external view returns(uint256);
    function transfer(address _to, uint256 _value)external returns(bool);
    function approve(address _spender, uint256 _value)external returns(bool);
    function transferFrom(address _from, address _to, uint256 _value)external returns(bool);    
    function allowance(address _owner, address _spender)external view returns(uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract MyFeebie is IBEP20 {
    using SafeMath for uint256;
    address payable public creator;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string public name = "Freebie Life Finance";
    string public symbol = "FRB";
    uint public decimals = 18;
    uint256 public _totalSupply;

//for presale 
    uint256 public presaleAmout;
    uint256 public totalInvestors;
    bool public startPresale;
    bool public endPresale;
    uint256 hardCap = 525000000000000000000; //525 BNB
    mapping(address => uint256) public investors;
    bool public liveProject;

    IUniswapV2Router02 _pancakeRouter;

    uint256 public holders;
    address[] public allAddresses;

    mapping(address => bool) private _excludedFees;
    address private vault;
    address public marketingWl;
    address private devWl;
    address private forLP;

    uint256 public balanceVault;
    uint256 public balanceFreebie;
    uint256 public deadlineFreebie;
    uint256 public currentFreebieNo;
    address public activatorFreebie;
    mapping(address => bool) public excludeFreebie;

    address[] public currentWinners50;
    address[] public claimedAddresses;
    uint256[] public AllrandomeNumbers;

    modifier ownerOnly {
        if (msg.sender == creator) {
            _;
        }
    }

    constructor() public{
        creator = msg.sender;
        _totalSupply = 1000000000000000000000000;
        _balances[creator] = _totalSupply;
        holders = 1;
        allAddresses.push(creator);
        vault = address(this);
        marketingWl = 0x2fB48b3E3973d0a874658B000a77E6fD446463dE;
        devWl = 0x5ff576c3f3CabD43309603843BF8E2B636F9253e; 
 // to where LP will go
        forLP = 0x000000000000000000000000000000000000dEaD;
        _pancakeRouter = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _excludedFees[creator]=true;
        _excludedFees[vault]=true;
        _excludedFees[marketingWl]=true;
        _excludedFees[devWl]=true;

        _transfer(creator, vault,       875000000000000000000000);
        _transfer(creator, marketingWl, 100000000000000000000000);
        _transfer(creator, devWl,        25000000000000000000000);

        excludeFreebie[creator]=true;
        excludeFreebie[vault]=true;
        excludeFreebie[marketingWl]=true;
        excludeFreebie[devWl]=true;  
    }

    function totalSupply() external override view returns(uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner)external override view returns(uint256 _returnedBalance){
        _returnedBalance = _balances[_owner];
        return _returnedBalance;
    }

    function _transfer(address _from, address _to, uint256 amount) internal {
      require(_from != address(0), "BEP20: Transfer from zero address");
      require(_to != address(0), "BEP20: Transfer to the zero address");
      if (_excludedFees[_from]) {
          _balances[_from] = _balances[_from].sub(amount);
          _balances[_to] = _balances[_to].add(amount);
          emit Transfer(_from, _to, amount);
          if (_balances[_from] == 0 && amount > 0) holders = holders.sub(1);
          if (_balances[_to].sub(amount) == 0) holders = holders.add(1);
          bool OnAddressList;
          for (uint i = 0; i < allAddresses.length; i++) {
              if (allAddresses[i] == _to) OnAddressList = true;
            } 
            if (OnAddressList == false) allAddresses.push(_to);
      } 
      if (_excludedFees[_from] == false) {
      uint256 fee;
      uint256 rest;
      fee = amount.div(20); // fee is 5% its 1/20 from all amount
      rest = amount.sub(fee);
        _balances[_from] = _balances[_from].sub(rest);
        _balances[_to] = _balances[_to].add(rest);       
        _balances[_from] = _balances[_from].sub(fee);
        _balances[vault] = _balances[vault].add(fee);

        emit Transfer(_from, _to, rest); 
        emit Transfer(_from, vault, fee);

        //update addresses list
        bool OnAddressList;
        for (uint i = 0; i < allAddresses.length; i++) {
              if (allAddresses[i] == _to) OnAddressList = true;
            } 
            if (OnAddressList == false) allAddresses.push(_to);
        //add fee to vault balance
        balanceVault = balanceVault.add(fee);
        //update holders counter
        if (_balances[_from] == 0 && amount > 0) holders = holders.sub(1);
        if (_balances[_to].sub(rest) == 0 ) holders = holders.add(1);
      }
    }

    function transfer(address _to, uint256 _value)external override returns(bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
      require(owner != address(0), "BEP20: approve from the zero address");
      require(spender != address(0), "BEP20: approve to the zero address");
      _allowances[owner][spender] = amount;
      emit Approval(owner, spender, amount);
    }

    function approve(address _spender, uint256 _value)external override returns(bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)external override returns(bool success){
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, _allowances[_from][msg.sender].sub(_value));
        return true;
    }

    function allowance(address _owner, address _spender)external override view returns(uint256 remaining){
        return _allowances[_owner][_spender];
    }

//start presale manualy
    function startPresaleManualy()public ownerOnly {
        startPresale = true;
    }

//check how much investor purchase 
    function tierOfInvestor(address _investorWL) public view returns(uint256) {
        return investors[_investorWL];
    }

//transfer BNB to contract
    function sendBNBtoContract()external payable returns(uint256 _amount){
        _amount = msg.value;
        return _amount;
    }
//Function to purchace in presale
    function sendToContract()external payable {
        require(startPresale, "Presale not active!");
        require(msg.value == 5000000000000000000 || //5 BNB
                msg.value == 2500000000000000000 || //2.5 BNB
                msg.value == 1000000000000000000 || //1 BNB
                msg.value == 500000000000000000  || //0.5 BNB       
                msg.value == 250000000000000000, //0.25 BNB
                "Amount must be: 0.25; 0.5; 1; 2,5; or 5 BNB");
        require(investors[msg.sender] == 0, "You already invested!");
        require((msg.value.add(presaleAmout)) <= hardCap, "Amount is too high (almost reach hardcap)");
        investors[msg.sender] = msg.value;
        presaleAmout = presaleAmout.add(msg.value);
        totalInvestors = totalInvestors.add(1);
        if (presaleAmout == hardCap) {
            startPresale = false;
            endPresale = true;
        }
    }

//claim tokens from presale
    function claimPresale()public {
        uint256 amount;
        require(endPresale, "Presale not finished yet.");
        require(liveProject, "Project not launched yet!");
        require(investors[msg.sender] > 0, "You are not in presale list!");
        require(investors[msg.sender] != 1, "You already claim your tokens!");      
        amount = investors[msg.sender].mul(1000);
        _transfer(vault, msg.sender, investors[msg.sender].mul(1000));
        investors[msg.sender] = 1;
    }

//Launch project manualy after presale is finished (Live and add LP)
    function liveProjectManualy()public ownerOnly payable{
        require(endPresale, "Presale not finished yet.");
        addMyLiquidity(350000000000000000000000, hardCap);
        liveProject = true;
    }
// Add liquidity directly from contract
    function addMyLiquidity(uint256 _tokensAmount, uint256 _BNBvalue)public ownerOnly payable {
        _approve(vault, address(0x10ED43C718714eb63d5aA57B78B54704E256024E), _tokensAmount);
        _pancakeRouter.addLiquidityETH {value: _BNBvalue}(
        vault,
        _tokensAmount,
        0,
        0,
        forLP,
        block.timestamp
    );
    }

//can use to add on exclude freebie list holders(pancake router etc.)
    function addToExcludedFromFreebie(address notwinner)public ownerOnly returns(address){
        excludeFreebie[notwinner] = true;
        return notwinner;
    }
    function removeFromExcludedFromFreebie(address maybeWinner)public ownerOnly returns(address){
        excludeFreebie[maybeWinner] = false;
        return maybeWinner;
    }

//change marketing wallet
    function SetMarketingWL(address _newMarketingWL) public ownerOnly returns(address) {
        marketingWl = _newMarketingWL;
        return marketingWl;
    }

//exclude from fee or include (if excluded)
    function ExcludeIncludeFee(address _addressExInc) public ownerOnly returns(bool){
        if (_excludedFees[_addressExInc] == false) _excludedFees[_addressExInc] = true;
        else _excludedFees[_addressExInc] = false;
        return _excludedFees[_addressExInc];
    }

    function GetRandomNumber(uint256 _i) private view returns(uint256){
        return uint(keccak256(abi.encodePacked(now, block.difficulty, allAddresses[_i])));
    }

    function checkClaimFromWinnersList(address _claimer)public view returns(bool _canClaim){
        for (uint i = 0; i < currentWinners50.length; i++) {
            if (currentWinners50[i] == _claimer) 
                _canClaim = true;
        }
    }

    function checkClaimedFreebie(address _claimer)public view returns(bool _Claimed){
        for (uint i = 0; i < claimedAddresses.length; i++) {
            if (claimedAddresses[i] == _claimer) _Claimed = true;
        }
        return _Claimed;
    }

    function get500TokensHolders() public view returns(uint256 _500Holders) {
        for (uint i = 0; i < allAddresses.length; i++) {
            if (_balances[allAddresses[i]] >= 500000000000000000000) 
                _500Holders = _500Holders.add(1);
        }
        return _500Holders;
    }

//function to start freebie 
    function StartFreebie()public returns(bool){
        require(_balances[msg.sender] >= 500000000000000000000, 'Your balance must be 500 or more tokens!');
        require(get500TokensHolders() >= 20, 'Holderst with balances >= 500 less then 20');
        require(block.timestamp > deadlineFreebie, 'Freebie already on air!');
        require(balanceVault >= 1200000000000000000000,'Vault not full enough, must be 1200 tokens there or more');
        if (balanceFreebie > 0) _transfer(vault, activatorFreebie,balanceFreebie);

        //reset winners list & claimed addresses lists
        if (currentFreebieNo > 0) 
        {
            delete currentWinners50;
            delete claimedAddresses;
            delete AllrandomeNumbers;
        }
        //reset first winner who activated Freebie
        currentWinners50.push(msg.sender);
        activatorFreebie = currentWinners50[0];     
        uint256 randomeNumberFull;
        uint256 randomeNumber;
        randomeNumberFull = GetRandomNumber(currentFreebieNo+1);
        bool done = true;
        for (uint j = 1; done; j++) 
        {
            uint256 randomForJ = randomeNumberFull.div(j);
            randomeNumber = randomForJ.mod(allAddresses.length);
            AllrandomeNumbers.push(randomeNumber);
            if (_balances[allAddresses[randomeNumber]] >= 500000000000000000000 && 
            excludeFreebie[allAddresses[randomeNumber]] == false && 
                checkClaimFromWinnersList(allAddresses[randomeNumber]) == false) 
            {       
                  currentWinners50.push(allAddresses[randomeNumber]);
                  if (currentWinners50.length == 10) {
                      done = false;
                  }
            }         
        } 
//Freebie 1000, so total 1200 (200 goes to marketing wallet)
        balanceVault = balanceVault.sub(1200000000000000000000);
        balanceFreebie = 1000000000000000000000;
        currentFreebieNo = currentFreebieNo.add(1);
        _transfer(vault, marketingWl, 200000000000000000000);
        deadlineFreebie = block.timestamp.add(86400); //86400 is 24h 
        return true;
    }

// Claim freebie for lucky winners
    function ClaimFreebie()public {
        require(balanceFreebie > 0, "Freebie not active yet! Or nothing left to claim.");
        require(checkClaimFromWinnersList(msg.sender),"You are not lucky, you are not in current winners list");
        require(checkClaimedFreebie(msg.sender) == false, "You already claim your freebie");        
        require(deadlineFreebie > block.timestamp, "Your time for claim is ower");
        _transfer(vault, msg.sender, 100000000000000000000);
        balanceFreebie = balanceFreebie.sub(100000000000000000000);
        claimedAddresses.push(msg.sender);
        if (balanceFreebie == 0) deadlineFreebie = block.timestamp;
    }

// Function for claim tokens for freebie activator
    function ClaimForActivatorFreebie()public {
        require(balanceFreebie > 0, "Balance of Freebie is zero, nothing left to claim bro!");
        require(msg.sender == currentWinners50[0], "You are not activator of the latest Freebie!");
        require(block.timestamp > deadlineFreebie, "Deadline still not finished yet!");
        _transfer(vault, currentWinners50[0],balanceFreebie);
        balanceFreebie = 0;
    }
}