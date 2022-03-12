// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./SafeMath.sol";

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

    string public name = "My Test FRB 1";
    string public symbol = "FRB1";
    uint public decimals = 18;
    uint256 public _totalSupply;
    uint256 public holders;
    address[] public allAddresses;

    mapping(address => bool) private _excludedFees;
    address private vault;
    address public marketingWl;
    address public devWl;

    enum Status {inactive, active}
    Status public freebieStatus;

    uint256 public balanceVault;
    uint256 public balanceFreebie;
    uint256 public deadlineFreebie;
    uint256 public currentFreebieNo;
    address public activatorFreebie;
    mapping(address => bool) public freebieList;
    mapping(address => bool) public excludeFreebie;

    address[] public currentWinners50;
    address[] public claimedAddresses;

    modifier ownerOnly {
        if (msg.sender == creator) {
            _;
        }
    }

    constructor() public{
        creator = msg.sender;
        _totalSupply = 1000000000000000000000000;
        _balances[creator] = 525000000000000000000000;
        allAddresses.push(creator);
        vault = address(this);
        _balances[vault] = 350000000000000000000000;
        allAddresses.push(vault);
        marketingWl = 0xAcf4A7d5D1C367cDDa9ade6dCF360a166e4Bd344;
        _balances[marketingWl] = 100000000000000000000000;
        allAddresses.push(marketingWl);
        devWl = 0x4b698D1231D35f6bE3E35B3EDa858906d3fbcd03; //Bonus Acc in metamask
        _balances[devWl] = 25000000000000000000000;
        allAddresses.push(devWl);
        holders = 4;
        _excludedFees[creator]=true;
        _excludedFees[vault]=true;
        _excludedFees[marketingWl]=true;
        _excludedFees[devWl]=true;
        excludeFreebie[creator]=true;
        excludeFreebie[vault]=true;
        excludeFreebie[marketingWl]=true;
        excludeFreebie[devWl]=true;
        //neet to exclude PCS contract also
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
      } else {
      uint256 fee;
      uint256 rest;
      fee = amount.div(20);
      rest = amount.sub(fee);
        //minuss from _from rest
        _balances[_from] = _balances[_from].sub(rest);
        //add to _to rest
        _balances[_to] = _balances[_to].add(rest);
        emit Transfer(_from, _to, rest);      
        bool OnAddressList;
        for (uint i = 0; i < allAddresses.length; i++) {
              if (allAddresses[i] == _to) OnAddressList = true;
            } 
            if (OnAddressList == false) allAddresses.push(_to);

        //sending fee to marketing Wl
        _balances[_from] = _balances[_from].sub(fee);
        _balances[vault] = _balances[vault].add(fee);
        emit Transfer(_from, vault, fee);

        //add fee to vault balance
        balanceVault = balanceVault.add(fee);
        if (_balances[_from] == 0 && amount > 0) holders = holders.sub(1);
        if (_balances[_to].sub(amount) == 0 ) holders = holders.add(1);
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

    //can use to add on exclude freebie list holders(pancake router etc.)
    function addToExcludedFromFreebie(address notwinner)public ownerOnly returns(bool){
        excludeFreebie[notwinner] = true;
        return true;
    }
    function removeFromExcludedFromFreebie(address maybeWinner)public ownerOnly returns(bool){
        excludeFreebie[maybeWinner] = false;
        return true;
    }

    function GetRandomNumber() private view returns(uint256){
        return uint(keccak256(abi.encodePacked(now, block.difficulty, holders)));
    }

    //function to check address to add it to winner list
    function checkAddresForWinners(address _candidat)private view returns(bool acceptedWinner){
        if (_balances[_candidat] >= 500000000000000000000 && 
            excludeFreebie[_candidat] == false) {
                acceptedWinner = true;
                for (uint a = 0; a < currentWinners50.length; a++) {
                    if(currentWinners50[a] == _candidat) return acceptedWinner = false;
                }
            } else return acceptedWinner = false;
            return acceptedWinner;
    }

    function checkClaimFromWinnersList(address _claimer)private view returns(bool _canClaim){
        for (uint i = 0; i < currentWinners50.length; i++) {
            if (currentWinners50[i] == _claimer) 
                _canClaim = true;
        }
    }

    function checkClaimedFreebie(address _claimer)private view returns(bool _Claimed){
        for (uint i = 0; i < claimedAddresses.length; i++) {
            if (claimedAddresses[i] == _claimer) _Claimed = true;
        }
        return _Claimed;
    }


    function get500TokensHolders() private view returns(uint256 _500Holders) {
        for (uint i = 0; i < allAddresses.length; i++) {
            if (_balances[allAddresses[i]] >= 500000000000000000000) 
                _500Holders = _500Holders.add(1);
        }
        return _500Holders;
    }

    function StartFreebie()public returns(bool){
        require(get500TokensHolders() >= 100, 'Holderst with balances >= 500 less then 100');
        if (deadlineFreebie > block.timestamp && freebieStatus == Status.active) freebieStatus = Status.inactive;
        require(freebieStatus == Status.inactive, 'Freebie already on air!');
        require(balanceVault >= 12000000000000000000000,'Vault not full enough, must be 12000 tokens there or more');
        if (balanceFreebie > 0) _transfer(vault, currentWinners50[0],balanceFreebie);
        freebieStatus = Status.active;

        //reset winners list
        delete currentWinners50;

        //reset claimed addresses list
        delete claimedAddresses;

        //reset first winner who activated Freebie
        currentWinners50[0] = msg.sender;

        //rendomly choose 49 winners
        //random numbers from holders numbers
        uint256 randomeNumber;
        randomeNumber = GetRandomNumber().mod(allAddresses.length);
        for (uint i = 1; i < 50; i++) {
            //choosed random address until its accepted
            while (checkAddresForWinners(allAddresses[randomeNumber])) {
                randomeNumber = GetRandomNumber().mod(allAddresses.length);
            }
            currentWinners50[i] = allAddresses[randomeNumber];          
        } 

        balanceVault = balanceVault.sub(12000000000000000000000);
        balanceFreebie = 10000000000000000000000;
        currentFreebieNo = currentFreebieNo.add(1);
        _transfer(vault, marketingWl, 2000000000000000000000);

      //counter for ends claim DONT FORGET TO CHANGE IT TO 24H  
        deadlineFreebie = block.timestamp.add(600); //now its 10 min
        return true;
    }

    function ClaimFreebie()public returns(bool){
        require(freebieStatus == Status.active, 'Freebie not active yet!');
        require(checkClaimFromWinnersList(msg.sender),"You are not lucky, you are not in current winners list");
        require(checkClaimedFreebie(msg.sender) == false, "You already claim your freebie");
        require(deadlineFreebie > block.timestamp, "Your time for claim is ower");
        _transfer(vault, msg.sender, 200000000000000000000);
        balanceFreebie = balanceFreebie.sub(200000000000000000000);
        claimedAddresses.push(msg.sender);
        if (balanceFreebie == 0) freebieStatus = Status.active;
        return true;
    }
}