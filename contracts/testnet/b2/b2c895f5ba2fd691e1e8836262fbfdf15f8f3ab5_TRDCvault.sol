/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: MIT


// TRDC Game

pragma solidity ^0.8.10;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
interface iBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface iBEP20Metadata is iBEP20 {
   
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract BEP20 is iBEP20, iBEP20Metadata {
    mapping(address => mapping(address => uint256)) private _allowances;
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    mapping(address => uint256) private _balances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address"); 
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }  
}

contract TRDCvault is BEP20 {
    using SafeMath for uint;
    using SafeMath for uint256;
    address private _owner;

    event GetThief(string ThiefName, uint ThiefPower);
    event GetCop(string CopName, uint CopPower);
    event GetWeapon(string WeaponName, uint WeaponPower);
    event BuyWeapon(string WeaponName, uint WeaponPower);
    event GetPlayerThiefs(string ThiefName, uint ThiefPower);
    event GetPlayerCops(string CopName, uint CopPower);
    event GetPlayerWeapons(string WeaponName, uint WeaponPower);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WithdrawalBNB(uint256 _amount, address to);
    event WithdrawalToken(address _tokenAddr, uint256 _amount, address to);
    event thiefHeist(string Bank, uint BankPower, string Thief, string Result, uint Amount);
    event copHeist(uint AmountCollected, uint AmountBurned, uint AmountBackToRewards);
    event totalThiefs (string _nameOfThief, uint _powerOfThief);
    event totalCops (string _nameOfCop, uint _powerOfCop);
    event GiveTreasure(BEP20 tokenAddress, uint Amount );

    BEP20 public currency; //0x7e8DB69dcff9209E486a100e611B0af300c3374e; TRDC
    BEP20 public treasure;
    address public dEaD= 0x000000000000000000000000000000000000dEaD;
    uint fractions = 10** 18;
    uint public cardPrice = 1000 * fractions;
    uint smallPortion;
    uint cardPower;
    uint randomThief;
    uint randomCop;
    uint number = 4;
    uint constant MAX_UINT = 2**256 - 1;
    uint public vVault = 500;
    uint public percentageCut = 15;
    uint endTime;
    string private guessThisOne;
    uint private randomNounce;
    uint public cardNounce;
    uint public roundsCount;
     
    struct CardThief{
        string tName;
        uint tPower;
    }
    struct CardCop{
        string cName;
        uint cPower;
    }
    struct Weapons{
        string wName;
        uint wPower;
        uint wPrice;
    }
    struct Banks{
        string bankName;
        uint bankPower;
        uint bankVault;
    }
    struct addBigBank{
        string bigBankName;
        uint bigBankPower;
        uint valutAmount;
    }
    struct ThiefRewards{
        address TRDCplayer;
        uint rewardsAmount;
    }
    struct CopRewards{
        address badCop;
        uint badRewards;
    }
    struct TreasureRewards{
        address gamePlayer;
        uint treasureVault;
    }
    
  
  mapping(address => bool) public player;
  mapping(address => bool) public playerIsHolder;
  mapping(address => bool) public playerIsCop;
  mapping(address => bool) public returnPlayer;
  mapping(address => CardThief[]) public thiefCardsOwned;
  mapping(address => CardCop[]) public copCardOwned;
  mapping(address => Weapons[]) public weaponsOwned;

    CardThief[] public cardThief;
    CardCop[] public cardCop;
    Weapons[] public weapons;
    Banks[] public banks;
    ThiefRewards[] public thiefRewards;
    CopRewards[] public copRewards;

  modifier setPower(address _Player){
      givePower();
     _; 
  }

    constructor () BEP20("TRDC-Game-V1", "|$|") payable{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        currency = BEP20(0xF8df86f7E8a16eaB149756843C9066967c562BB2);//should change to TRDC address used for testing
    }  
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function startTheGame(string memory guess) external onlyOwner{
        uint _roundTime = block.timestamp + 2 hours; 
        endTime = _roundTime;
        guessThisOne = guess;
        roundsCount++;
    }
    function startTheGameInternal() internal{
        uint _roundTime = block.timestamp + 2 hours; 
        endTime = _roundTime;
        roundsCount++;
    }
    function timeLeft() public view returns(uint TimeLeft){
        TimeLeft = endTime.sub(block.timestamp);
        return(TimeLeft);
    }
    function setPercentageCut(uint _percentageCut) internal onlyOwner{
        percentageCut = _percentageCut;
    }
    function vaultMinAmount(uint _vVault) external onlyOwner{
        vVault = _vVault;
    }
    function setCurrency (address CryptoCurrency, uint decimal) external onlyOwner {
        currency = BEP20(CryptoCurrency);
        fractions = 10** decimal;
    }
    function setTreasure(address CryptoCurrency, uint decimal) external onlyOwner{
        treasure = BEP20(CryptoCurrency);
        fractions = 10** decimal;
    }
    function addBank (string memory _bankName,uint _bankPower, uint _bankVault) public onlyOwner{
        Banks memory newBanks = Banks({
            bankName: _bankName,
            bankPower: _bankPower,
            bankVault: _bankVault
        });
        banks.push(newBanks);
    }
    function editBank(uint bankIndex, string memory _bankName, uint _bankPower, uint _bankVault) public onlyOwner{
        banks[bankIndex].bankName = _bankName;
        banks[bankIndex].bankPower = _bankPower;
        banks[bankIndex].bankVault = _bankVault;
    }
    function deleteBank(uint bankIndex) public onlyOwner{
        banks[bankIndex] = banks[banks.length -1];
        banks.pop();
    }
    function addThief (string memory _tName, uint _tPower) public onlyOwner{
        CardThief memory newCardThief = CardThief({
            tName: _tName,
            tPower: _tPower
        });
        cardThief.push(newCardThief);
    }
    function editThief(uint thiefIndex, string memory _tName, uint _tPower) public onlyOwner{
        cardThief[thiefIndex].tName = _tName;
        cardThief[thiefIndex].tPower = _tPower;
    }
    function deleteThief(uint thiefIndex) public onlyOwner{
        cardThief[thiefIndex] = cardThief[cardThief.length -1];
        cardThief.pop();
    }
    function getThiefs() public returns (string memory nameOfThief, uint powerOfThief){
        require(cardThief.length !=0, "Thiefs are not yet created");
        for (uint i=0; i<cardThief.length; i++ ){
            nameOfThief = cardThief[i].tName;
            powerOfThief = cardThief[i].tPower;
            emit totalThiefs (nameOfThief, powerOfThief);
        }   
    }
    function addCop (string memory _cName, uint _cPower) public onlyOwner{
        CardCop memory newCardCop = CardCop({
            cName: _cName,
            cPower: _cPower
        });
        cardCop.push(newCardCop);
    }
    function editCop(uint copIndex, string memory _cName, uint _cPower) external onlyOwner{
        cardCop[copIndex].cName = _cName;
        cardCop[copIndex].cPower = _cPower;
    }
    function deleteCop(uint copIndex) public onlyOwner{
        cardCop[copIndex] = cardCop[cardCop.length -1];
        cardCop.pop();
    }
    function getCops() external returns (string memory nameOfCop, uint powerOfCop){
        require(cardCop.length !=0, "Cops are not yet created");
        for (uint i=0; i<cardCop.length; i++ ){
            nameOfCop = cardCop[i].cName;
            powerOfCop = cardCop[i].cPower;
            emit totalCops (nameOfCop, powerOfCop);
        }   
    }
    function addWeapon (string memory _wName, uint _wPower, uint _wPrice) external onlyOwner{
        Weapons memory newWeapons = Weapons({
            wName: _wName,
            wPower: _wPower,
            wPrice: _wPrice
        });
        weapons.push(newWeapons);
    }
    function editWeapon(uint weaponIndex, string memory _wName, uint _wPower) external onlyOwner{
        weapons[weaponIndex].wName = _wName;
        weapons[weaponIndex].wPower = _wPower;
    }
    function deleteWeapon(uint weaponIndex) external onlyOwner{
        weapons[weaponIndex] = weapons[weapons.length -1];
        weapons.pop();
    }
    function buyThiefCard() internal returns (string memory nameOfThief, uint powerOfThief){
        require(cardThief.length !=0, "Thiefs are not yet created");
        randomThief = jeffRandomness() % cardThief.length;
        emit GetThief(nameOfThief = cardThief[randomThief].tName, powerOfThief = cardThief[randomThief].tPower);
        thiefCardsOwned[msg.sender].push(CardThief(nameOfThief, powerOfThief));  
    }
    function buyCopCard() internal returns (string memory nameOfCop, uint powerOfCop){
        require(cardCop.length !=0, "Cops are not yet created");
        randomCop = jeffRandomness() % cardCop.length;
        emit GetCop(nameOfCop = cardCop[randomCop].cName, powerOfCop = cardCop[randomCop].cPower); 
        copCardOwned[msg.sender].push(CardCop(nameOfCop, powerOfCop));   
    }
    function getPlayerThiefs() external returns(string memory _thiefName, uint _thiefPower){  
        for(uint i=0; i< thiefCardsOwned[msg.sender].length; i++){
            _thiefName = thiefCardsOwned[msg.sender][i].tName;
            _thiefPower = thiefCardsOwned[msg.sender][i].tPower;
            emit GetPlayerThiefs(_thiefName, _thiefPower);
        }
    }
    function getPlayerCops() external returns(string memory _copName, uint _copPower){  
        for(uint i=0; i< copCardOwned[msg.sender].length; i++){
            _copName = copCardOwned[msg.sender][i].cName;
            _copPower = copCardOwned[msg.sender][i].cPower;
            emit GetPlayerCops(_copName, _copPower);
        }   
    }
    function getPlayerWeapons() external returns(string memory _weaponName, uint _weaponPower){  
        for(uint i=0; i< weaponsOwned[msg.sender].length; i++){
            _weaponName = weaponsOwned[msg.sender][i].wName;
            _weaponPower = weaponsOwned[msg.sender][i].wPower;
            emit GetPlayerWeapons(_weaponName, _weaponPower);
        }   
    }
    function buyWeapon(uint weaponToBuy) external returns (string memory nameOfWeapon, uint powerOfWeapon){
        require(weapons.length !=0, "There are no Weapons yet");
        uint priceOfWeapon = weapons[weaponToBuy].wPrice;
        currency.transferFrom(msg.sender, address(this), priceOfWeapon);
        emit GetWeapon(nameOfWeapon = weapons[weaponToBuy].wName, powerOfWeapon = weapons[weaponToBuy].wPower); 
        weaponsOwned[msg.sender].push(Weapons(nameOfWeapon, powerOfWeapon, priceOfWeapon));   
    }
    function deletePlayerThiefCard(uint cardsIndex) internal{
       thiefCardsOwned[msg.sender][cardsIndex] = thiefCardsOwned[msg.sender][thiefCardsOwned[msg.sender].length -1];
       thiefCardsOwned[msg.sender].pop();
    }
    function deletePlayerCopCard(uint cardsIndex) internal{
        copCardOwned[msg.sender][cardsIndex] = copCardOwned[msg.sender][copCardOwned[msg.sender].length -1];
        copCardOwned[msg.sender].pop();
    }
    function deleteWeaponCard(uint weaponIndex) internal{
        weaponsOwned[msg.sender][weaponIndex] = weaponsOwned[msg.sender][weaponsOwned[msg.sender].length -1];
        weaponsOwned[msg.sender].pop();
    }
    function useWeapon(uint weaponIndex, uint cardIndex) external{
        uint weaponPower = weaponsOwned[msg.sender][weaponIndex].wPower;
        uint thiefCardPower = thiefCardsOwned[msg.sender][cardIndex].tPower;
        uint updatedCardPower = weaponPower.add(thiefCardPower);
        deleteWeaponCard(weaponIndex);
        thiefCardsOwned[msg.sender][cardIndex].tPower = updatedCardPower;
    }
    function addThiefReward(address _TRDCplayer, uint _rewardsAmount) internal{
        ThiefRewards memory newThiefRewards = ThiefRewards({
            TRDCplayer: _TRDCplayer,
            rewardsAmount: _rewardsAmount
        });
        thiefRewards.push(newThiefRewards);
    }
    function updateThiefReward(uint _updateAmount) internal{
        uint oldAmount;
        uint newAmount;
        for (uint i=0; i<thiefRewards.length; i++){
            if (thiefRewards[i].TRDCplayer == msg.sender){
                newAmount = _updateAmount;
                oldAmount = thiefRewards[i].rewardsAmount;
                thiefRewards[i].rewardsAmount = oldAmount.add(newAmount);
                return();
            } 
        }
        addThiefReward(msg.sender, _updateAmount);
    }
    function addCopReward (address _badCop, uint _badRewards) internal{
        CopRewards memory newCopRewards = CopRewards({
            badCop: _badCop,
            badRewards: _badRewards
        });
        copRewards.push(newCopRewards);
    }
    function updateCopReward(uint _updateAmount) internal{
        uint oldAmount;
        uint newAmount;
        for (uint i=0; i<copRewards.length; i++){
            if (copRewards[i].badCop == msg.sender){
                newAmount = _updateAmount;
                oldAmount = copRewards[i].badRewards;
                copRewards[i].badRewards = oldAmount.add(newAmount);
                return();
            }
        }
        addCopReward(msg.sender, _updateAmount);
    }
    function giveTreasure(uint _amount) internal{
        treasure.transfer(msg.sender, _amount);
        addReturnPlayer(msg.sender);
        emit GiveTreasure(treasure, _amount);
    }
    function setSmallPortion(uint _SmallPortionTreasure) external onlyOwner{
        smallPortion = _SmallPortionTreasure;
    }
  function deleteThiefRewards(uint rewardIndex) internal{
        thiefRewards[rewardIndex] = thiefRewards[thiefRewards.length -1];
        thiefRewards.pop();
    }
    function deleteCopRewards(uint rewardIndex) internal{
        copRewards[rewardIndex] = copRewards[copRewards.length -1];
        copRewards.pop();
    }
  function addToPlayersList(address _player) internal {
      if (player[_player] != true){
          player[_player] = true;
      }
  }
  function addPlayerVault(address _player) internal{
      if (playerIsHolder[_player] != true){
          playerIsHolder[_player] = true;
      }  
  }
  function addCopVault(address _player) internal{
      if (playerIsCop[_player] != true){
          playerIsCop[_player] = true;
      }
  }
  function addReturnPlayer(address _player) internal{
      if(returnPlayer[_player] != true){
          returnPlayer[_player] = true;
      }
  }
  function removeFromPlayersList(address _player) internal {
    player[_player] = false;
  }

  function jeffRandomness() private returns(uint){
      uint thisRandom = uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
      msg.sender, guessThisOne, randomNounce)));
      randomNounce++;
      return thisRandom;
  }
  function givePower() internal {
        cardPower = jeffRandomness() % number;
        if (cardPower == 0){
            cardPower == 1;
        }
        cardNounce++;
  }
  function giveBankPower(uint bankIndex) internal {
      uint bankPower;
        bankPower = jeffRandomness() % banks.length;
        if (bankPower == 0){
            bankPower == banks.length;
        }
        banks[bankIndex].bankPower = bankPower;
  }
  function changePrice(uint256 _cardPrice) external onlyOwner {
        cardPrice = _cardPrice * fractions;
  }
  function addPlayer() internal{
      if (player[msg.sender] != true){
          addToPlayersList(msg.sender);
      }
  }
  function addVault() internal{
      if (playerIsHolder[msg.sender] != true){
          addPlayerVault(msg.sender);
      }
  }
  function addCopVault() internal{
      if (playerIsCop[msg.sender] != true){
          addCopVault(msg.sender);
      }
  }

  function buyCard() external setPower(msg.sender){
      if(endTime < block.timestamp){
          startTheGameInternal();
      }
      addPlayer();
      currency.transferFrom(msg.sender, address(this), cardPrice);//Trasfer from User to this contract TRDC token (price of game card)
      _mint(msg.sender, 1);
      if (cardPower == 1) {
         buyThiefCard();
      }
      if (cardPower == 2) {
         buyThiefCard();
      }
      if (cardPower == 3) {
         _mint(msg.sender, 1);
         buyThiefCard();
         buyCopCard();
      }
  }
  function resetBankPower(uint bankIndex) internal returns (string memory BankName, uint BankPower){
      if (banks[bankIndex].bankVault >= cardPrice.mul(2)){
          banks[bankIndex].bankPower++;
          return(BankName, BankPower);
      }
      giveBankPower(bankIndex);
      BankName = banks[bankIndex].bankName;
      BankPower = banks[bankIndex].bankPower;
  }
  function approveOnBothSides()public {
      //first get approval from currency contract
      approve(msg.sender, MAX_UINT);//approval should be called at wallet connect
  }
  
  function startHeistThief (uint cardType, uint cardToUse, uint bankToHeist) public  returns (string memory heistResult){
      uint _bankVault= banks[bankToHeist].bankVault;
      require(player[msg.sender], "Sorry you are not a player");
      require(endTime > block.timestamp, "The round has ended");
      require(_bankVault > 0, "The bank vault is empty!");
      uint _tPower;
      uint _value;
      uint bankPower = banks[bankToHeist].bankPower;
      string memory bName = banks[bankToHeist].bankName;
      string memory _tName = thiefCardsOwned[msg.sender][cardToUse].tName;
      
      resetBankPower(bankToHeist);
      banks[bankToHeist].bankVault = _bankVault.add(cardPrice);
      _bankVault= banks[bankToHeist].bankVault;
      if (cardType== 1){
          _tPower = thiefCardsOwned[msg.sender][cardToUse].tPower;
          if (_tPower > bankPower){
              _value = _bankVault.mul(60).div(100);
              updateThiefReward(_value);
              heistResult = "You Win, Please wait till the Heist end";
          }
          if (_tPower == bankPower){
                _value = cardPrice.div(2);
                updateThiefReward(_value);
                heistResult = "You Draw, Please wait till the Heist end"; 
              }
              if (_tPower < bankPower){
                  deletePlayerThiefCard(cardToUse);
                  endHeist();
                  removePlayer();
                  if(treasure.balanceOf(address(this)) > smallPortion && smallPortion !=0){
                      if (returnPlayer[msg.sender] != true){
                      giveTreasure(smallPortion);
                  }
                  } 
                return("You Lost, try again");
              }
      }
      deletePlayerThiefCard(cardToUse);
      endHeist();
      emit thiefHeist(bName, _tPower, _tName, heistResult, _value );
      return(heistResult);
  }
  function runCop(uint cardToUse) external returns(uint amountCollected, uint amountBurned, uint amountbackToRewards){
      require(player[msg.sender], "Sorry you are not a player");
      require(block.timestamp >= (endTime.sub(90 minutes)), "You can run the cop only after 30 min of round start time!");
      uint _cPower;
      uint _pVault;
      uint _toBurn;
      uint _toRewards;
      uint _toCop;
      uint moneyToSteal = cardCop.length;
      _cPower = copCardOwned[msg.sender][cardToUse].cPower;
          if (_cPower > moneyToSteal){
              for (uint i=0; i<thiefRewards.length; i++){
                  _pVault = thiefRewards[i].rewardsAmount;
                  if (_pVault > vVault ){
                      _toBurn = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _toRewards = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _toCop = _pVault.sub(_pVault.mul(percentageCut).div(100));
                      _pVault = _pVault.sub(_toBurn.add(_toRewards).add(_toCop));
                      thiefRewards[i].rewardsAmount = _pVault;
                      currency.transfer(dEaD, _toBurn);
                      updateCopReward(_toCop);
                      addVault();
                      deletePlayerCopCard(cardToUse);
                      removePlayer();
                      emit copHeist(_toCop, _toBurn, _toRewards);
                      return(_toCop, _toBurn, _toRewards);
                  }
              } 
          }
          else{
                  deletePlayerCopCard(cardToUse);
                  if(treasure.balanceOf(address(this)) > smallPortion && smallPortion !=0){
                      if (returnPlayer[msg.sender] != true){
                          removePlayer();
                          giveTreasure(smallPortion);
                  }
                  } 
              }     
  }
  function endHeist() internal {
      transferFrom(msg.sender, dEaD, 1);
      addVault();
  }
  function removePlayer()internal{
      if  (balanceOf(msg.sender) == 0){
          removeFromPlayersList(msg.sender);
      }
  }
  function claimRewardsThief() external returns(uint _thiefReward){
      require(playerIsHolder[msg.sender], "Sorry you you don't have any rewards");
      require(block.timestamp <= endTime.sub(1 hours), "Please wait one hour after round starts");
      removePlayer();
      playerIsHolder[msg.sender] = false;
      address _thiefAddress;
     for(uint i=0; i<thiefRewards.length; i++){
         _thiefAddress = thiefRewards[i].TRDCplayer;
         _thiefReward = thiefRewards[i].rewardsAmount;
         if(_thiefAddress == msg.sender){
             deleteThiefRewards(i);
             currency.transfer(msg.sender, _thiefReward);
             return(_thiefReward);
         }
     }
  }
  function claimRewardsCop() external returns(uint _copReward){
      require(playerIsCop[msg.sender], "Sorry you you don't have any rewards");
      require(block.timestamp <= endTime.sub(1 hours), "Please wait one hour after round starts");
      removePlayer();
      playerIsCop[msg.sender] = false;
      address _copAddress;
     for(uint i=0; i<copRewards.length; i++){
         _copAddress = copRewards[i].badCop;
         _copReward = copRewards[i].badRewards;
         if(_copAddress == msg.sender){
             deleteCopRewards(i);
             currency.transfer(msg.sender, _copReward);
             return(_copReward);
         }
     }
  }
  function withdrawalToken(address _tokenAddr, uint256 _amount, address to) external onlyOwner() {
        iBEP20 token = iBEP20(_tokenAddr);
        emit WithdrawalToken(_tokenAddr, _amount, to);
        token.transfer(to, _amount);
    }
    
    function withdrawalBNB(uint256 _amount, address to) external onlyOwner() {
        require(address(this).balance >= _amount);
        emit WithdrawalBNB(_amount, to);
        payable(to).transfer(_amount);
    }

    receive() external payable {}
}

//********************************************************
// Proudly Developed by MetaIdentity ltd. Copyright 2022
//********************************************************