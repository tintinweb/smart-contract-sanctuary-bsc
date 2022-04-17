/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

// SPDX-License-Identifier: MIT


// TRDC Game   فكرة: حمزة بنالي Idea: Hamza Banaly
// برمجة: جعفر كريّم Programed by: Jaafar Krayem

pragma solidity ^0.8.13;

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
        require(_totalSupply <= (21000000 *10**18), "Total supply reached"); 
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WithdrawalBNB(uint256 _amount, address to);
    event WithdrawalToken(address _tokenAddr, uint256 _amount, address to);
    event thiefHeist(string Bank, uint BankPower, string Thief, uint ThiefPower, string Result, uint Amount);
    event copHeist(uint AmountCollected, uint AmountBurned, uint AmountBackToRewards);
    event GiveTreasure(BEP20 tokenAddress, uint Amount );
    event RewardsClaimed(uint256 Amount);

    BEP20 public currency; //TRDC
    BEP20 public treasure;
    address public dEaD= 0x000000000000000000000000000000000000dEaD;
    uint fractions = 10** 18;
    uint fractionsT;
    uint public cardPrice = 1200 * fractions;
    uint smallPortion;
    uint cardPower;
    uint randomThief;
    uint randomCop;
    uint private number;
    uint constant MAX_UINT = 2**256 - 1;
    uint public vVault = 2500 * fractions;
    uint public percentageCut = 20;
    uint endTime;
    string private guessThisOne;
    string private guessThisToo;
    uint private randomNounce;
    uint public cardNounce;
    uint public roundsCount;
    uint public gamePublish;
    bool public gameRunning = false;
    //uint public bankVaults;
    uint public totalRewards;
    uint public totalBurned;
    uint public playerCount;
    uint public bVA = 4;
    uint public rewardPercentage = 60;
    uint public priceOfShield = 5000 * fractions;
    uint public bankVaultPowerReset = 2500 * fractions;
    uint public toStart;
    uint public copsYes = 1;
    uint public copsYesC;
    uint public thiefYesC;
    uint public half = 5;
     
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
    }/*
    struct BigBank{
        string bigBankName;
        BEP20 currency;
        uint bigBankPower;
        uint vaultAmount;
    }*/
    struct TreasureRewards{
        address TRDCgamePlayer;
        uint treasureVault;
    }
    struct gamePlayer{
        uint256 gamerID;
        uint256 gamerVault;
        uint256 nThiefCards;
        uint256 nCopCards;
        uint256 nWeapons;
    }
  mapping(address => bool) public gameOperator;
  mapping(address => bool) public player;
  mapping(address => bool) public playerIsHolder;
  mapping(address => bool) public playerIsCop;
  mapping(address => bool) public returnPlayer;
  mapping(address => bool) public isShielded;
  mapping(address => bool) public busted;
  mapping(uint => address) public PlayerID;
  mapping(address => gamePlayer) public playerStats;
  mapping(address => CardThief[]) public thiefCardsOwned;
  mapping(address => CardCop[]) public copCardOwned;
  mapping(address => Weapons[]) public weaponsOwned;

    CardThief[] public cardThief;
    CardCop[] public cardCop;
    Weapons[] public weapons;
    Banks[] public banks;
    //BigBank[] public bigBank;

  modifier onlyOperator(){
      require(gameOperator[msg.sender] == true,"o operator!");
      _;
  }  
  modifier haveRewards(address _player){
      require(playerIsHolder[_player] == true || playerIsCop[_player] == true, "no rewards!");
      _;
  }
  modifier setPower(address _Player){
      givePower();
     _; 
  }

    constructor (uint _number, string memory _guessThisToo) BEP20("TRDC-Game-V2", "|$|") payable{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
        currency = BEP20(0x7e8DB69dcff9209E486a100e611B0af300c3374e);
        number = _number;
        guessThisOne = _guessThisToo;
        gameOperator[_owner] = true;
        gamePublish = block.timestamp;
        playerCount =0;
        //rewardPercentage = 60;
    }  
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function BArray(uint _bA) external onlyOperator{
        bVA = _bA;
    }
    function makeOperator(address _operator) external onlyOwner{
        require(gameOperator[_operator] != true, "already!");
        gameOperator[_operator] = true;
    }
    function removeOperator(address _operator) external onlyOwner{
        require(gameOperator[_operator] != false, "not found!");
        gameOperator[_operator] = false;
    }
    function yesCops(uint _copsYes) external onlyOperator{
        copsYes = _copsYes;
    }
    function changeHalf(uint _half) external onlyOperator{
        half = _half;
    }
    function startTheGame(string memory guess) public onlyOperator{
        uint _roundTime = block.timestamp + 2 hours; 
        endTime = _roundTime;
        guessThisOne = guess;
        roundsCount++;
        gameRunning = true;
        copsYesC = 0;
        thiefYesC = 0;
    }
    function startTheGameInternal() internal{
        uint _roundTime = block.timestamp + 2 hours; 
        endTime = _roundTime;
        guessThisOne = guessThisToo;
        roundsCount++;
        gameRunning = true;
        copsYesC = 0;
        thiefYesC= 0;
    }
    function pauseGame() external onlyOwner{
        gameRunning = false;
    }
    function setRewardPercentage(uint256 _percentage) external onlyOwner{
        rewardPercentage = _percentage;
    }
    function TRDCplayer(address _player) public view haveRewards(_player) returns(bool state, bool claimable, uint256 rewardBalance){
        rewardBalance = playerStats[_player].gamerVault;
        //uint256 claimTime = endTime.sub(block.timestamp);
        state = true;
        claimable = false;
        if(copsYesC >= copsYes){      //(claimTime <= 1 hours)
            claimable = true;
        }
        return(state, claimable, rewardBalance.div(fractions));  
    }
    function timeLeft() public view returns(uint TimeLeft){
        TimeLeft = endTime.sub(block.timestamp);
        return(TimeLeft);
    }
    function setPercentageCut(uint _percentageCut) external onlyOperator{
        percentageCut = _percentageCut;
    }
    function vaultMinAmount(uint _vVault) external onlyOperator{
        vVault = _vVault.mul(fractions);
    }
    function setCurrency (BEP20 CryptoCurrency, uint decimal) external onlyOperator {
        currency = BEP20(CryptoCurrency);
        fractions = 10** decimal;
    }
    function setTreasure(address CryptoCurrency, uint decimal) external onlyOperator{
        treasure = BEP20(CryptoCurrency);
        fractionsT = 10** decimal;
    }
    /*
    function addBigBank (string memory _bankName, BEP20 _currency ,uint _bankPower, uint _bankVault) external onlyOperator{
        BigBank memory newBigBank = BigBank({
            bigBankName: _bankName,
            currency: _currency,
            bigBankPower: _bankPower,
            vaultAmount: _bankVault
        });
        bigBank.push(newBigBank);
    }
    function editBigBank(uint bankIndex, string memory _bankName, BEP20 _currency, uint _bankPower, uint _bankVault) external onlyOperator{
        bigBank[bankIndex].bigBankName = _bankName;
        bigBank[bankIndex].currency = _currency;
        bigBank[bankIndex].bigBankPower = _bankPower;
        bigBank[bankIndex].vaultAmount = _bankVault;
    }
    function deleteBigBank(uint bankIndex) external onlyOperator{
        bigBank[bankIndex] = bigBank[bigBank.length -1];
        bigBank.pop();
    }
    */
    function getBankVaults() public view returns(uint){
        uint _bankVaults;
        for(uint i=0; i<banks.length; i++){
            uint bVaults = banks[i].bankVault;
            _bankVaults += bVaults;
        }
        return(_bankVaults);
    }

    function addBank (string memory _bankName,uint _bankPower, uint _bankVault) public onlyOperator{
        //require(bankVaults > );
        Banks memory newBanks = Banks({
            bankName: _bankName,
            bankPower: _bankPower,
            bankVault: _bankVault.mul(fractions)
        });
        banks.push(newBanks);
        //bankVaults += _bankVault.mul(fractions);
    }
    function editBank(uint bankIndex, uint _bankPower, uint _bankVault) external onlyOperator{
        //bankVaults -= banks[bankIndex].bankVault;
        banks[bankIndex].bankPower = _bankPower;
        banks[bankIndex].bankVault = _bankVault.mul(fractions);
        //bankVaults += banks[bankIndex].bankVault;
    }
    function deleteBank(uint bankIndex) external onlyOperator{
        banks[bankIndex] = banks[banks.length -1];
        banks.pop();
    }
    function addThief (string memory _tName, uint _tPower) public onlyOperator{
        CardThief memory newCardThief = CardThief({
            tName: _tName,
            tPower: _tPower
        });
        cardThief.push(newCardThief);
    }
    function editThief(uint thiefIndex, uint _tPower) external onlyOperator{
        //cardThief[thiefIndex].tName = _tName;
        cardThief[thiefIndex].tPower = _tPower;
    }
    function deleteThief(uint thiefIndex) public onlyOwner{
        cardThief[thiefIndex] = cardThief[cardThief.length -1];
        cardThief.pop();
    }
    function addCop (string memory _cName, uint _cPower) public onlyOperator{
        CardCop memory newCardCop = CardCop({
            cName: _cName,
            cPower: _cPower
        });
        cardCop.push(newCardCop);
    }
    function editCop(uint copIndex, uint _cPower) external onlyOperator{
        //cardCop[copIndex].cName = _cName;
        cardCop[copIndex].cPower = _cPower;
    }
    function deleteCop(uint copIndex) public onlyOwner{
        cardCop[copIndex] = cardCop[cardCop.length -1];
        cardCop.pop();
    }

    function addWeapon (string memory _wName, uint _wPower, uint _wPrice) external onlyOperator{
        Weapons memory newWeapons = Weapons({
            wName: _wName,
            wPower: _wPower,
            wPrice: _wPrice.mul(fractions)
        });
        weapons.push(newWeapons);
    }
    function editWeapon(uint weaponIndex, uint _wPower, uint _wPrice) external onlyOperator{
        weapons[weaponIndex].wPower = _wPower;
        weapons[weaponIndex].wPrice = _wPrice.mul(fractions);
    }
    function deleteWeapon(uint weaponIndex) external onlyOperator{
        weapons[weaponIndex] = weapons[weapons.length -1];
        weapons.pop();
    }
    function giveThiefCardV1(address _V1player, uint _thiefIndex, uint _powerOfThief) external onlyOperator
    returns (string memory nameOfThief){
        emit GetThief(nameOfThief = cardThief[_thiefIndex].tName, _powerOfThief);
        thiefCardsOwned[_V1player].push(CardThief(nameOfThief, _powerOfThief));
        _mint(_V1player, 1);
        addPlayer(_V1player);
        playerStats[_V1player].nThiefCards++; 
    }
    function giveCopCardV1(address _V1player, uint _copIndex) external onlyOperator
    returns (string memory nameOfCop, uint powerOfCop){
        emit GetCop(nameOfCop = cardCop[_copIndex].cName, powerOfCop = cardCop[_copIndex].cPower); 
        copCardOwned[_V1player].push(CardCop(nameOfCop, powerOfCop)); 
        _mint(_V1player, 1);
        addPlayer(_V1player);
        playerStats[_V1player].nCopCards++;
    }
    function giveWeaponV1(address _V1player, uint _weaponIndex) external onlyOperator
    returns (string memory nameOfWeapon, uint powerOfWeapon){
        emit GetWeapon(nameOfWeapon = weapons[_weaponIndex].wName, powerOfWeapon = weapons[_weaponIndex].wPower); 
        weaponsOwned[_V1player].push(Weapons(nameOfWeapon, powerOfWeapon,0));
        playerStats[_V1player].nWeapons++; 
    }
    function buyThiefCard() internal returns (string memory nameOfThief, uint powerOfThief){
        require(cardThief.length !=0, "nT");
        randomThief = jeffRandomness() % cardThief.length;
        emit GetThief(nameOfThief = cardThief[randomThief].tName, powerOfThief = cardThief[randomThief].tPower);
        thiefCardsOwned[msg.sender].push(CardThief(nameOfThief, powerOfThief));
        playerStats[msg.sender].nThiefCards++; 
    }
    function buyCopCard() internal returns (string memory nameOfCop, uint powerOfCop){
        require(cardCop.length !=0, "nC");
        randomCop = jeffRandomness() % cardCop.length;
        emit GetCop(nameOfCop = cardCop[randomCop].cName, powerOfCop = cardCop[randomCop].cPower); 
        copCardOwned[msg.sender].push(CardCop(nameOfCop, powerOfCop));
        playerStats[msg.sender].nCopCards++;  
    }
    function buyWeapon(uint weaponToBuy) external returns (string memory nameOfWeapon, uint powerOfWeapon){
        require(weapons.length !=0, "nW");
        uint priceOfWeapon = weapons[weaponToBuy].wPrice;
        currency.transferFrom(msg.sender, address(this), priceOfWeapon);
        emit GetWeapon(nameOfWeapon = weapons[weaponToBuy].wName, powerOfWeapon = weapons[weaponToBuy].wPower); 
        weaponsOwned[msg.sender].push(Weapons(nameOfWeapon, powerOfWeapon, priceOfWeapon));
        playerStats[msg.sender].nWeapons++;
        disToVaults(priceOfWeapon);  
    }
    function buyShield() external{
        require(currency.balanceOf(msg.sender) >= priceOfShield,"No TRDC!");
        require(isShielded[msg.sender] != true,"ok!");
        currency.transferFrom(msg.sender, address(this), priceOfShield);
        isShielded[msg.sender] = true;
        disToVaults(priceOfShield);
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
        playerStats[msg.sender].nWeapons--;
    }
    function giveTreasure(uint _amount) internal{
        treasure.transfer(msg.sender, _amount);
        addReturnPlayer(msg.sender);
        emit GiveTreasure(treasure, _amount);
    }
    function setSmallPortion(uint _SmallPortionTreasure) external onlyOperator{
        smallPortion = _SmallPortionTreasure;
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
        require(number != 0, "0");
        cardPower = jeffRandomness() % number;
        if(cardPower % 2 == 0){
            cardPower = 1;//odd
        }
        else{
            cardPower = 2;//even
        }
        cardNounce++;
  }
  function giveBankPower(uint bankIndex) internal {
      uint bankPower;
        bankPower = jeffRandomness() % banks.length;
        if (bankPower == 0){
            bankPower = banks.length;
        }
        banks[bankIndex].bankPower = bankPower;
  }
  function changePrice(uint256 _cardPrice) external onlyOperator {
        cardPrice = _cardPrice * fractions;
  }
  function shieldprice(uint256 _priceOfShield)external onlyOperator{
      priceOfShield = _priceOfShield * fractions;
  }
  function addPlayer(address _player) internal{
      if (player[_player] != true){
          playerCount ++;
          addToPlayersList(_player);
          playerStats[_player].gamerID = playerCount;
          PlayerID[playerCount] = _player;
      }
  }
  function disToVaults(uint _amount) internal {
      for(uint i=0; i<bVA; i++){
          banks[i].bankVault += _amount.div(bVA);
          resetBankPower(i); 
      }
  }
  function buyCard() external setPower(msg.sender) returns (uint CardType){
      require(gameRunning != false, "gp");
      require(currency.balanceOf(msg.sender) >= cardPrice, "trdc");
      if(endTime < block.timestamp){
          startTheGameInternal();
      }
      addPlayer(msg.sender);
      if(randomNounce %2 == 0){
          cardPower = 1;
      }
      currency.transferFrom(msg.sender, address(this), cardPrice);//Trasfer from User to this contract TRDC token (price of game card)
      disToVaults(cardPrice);
      _mint(msg.sender, 1);
      if (cardPower == 1) {
         buyThiefCard();
         return (cardPower);
      }
      else{
         buyCopCard();
         return (cardPower);
      }
  }
  function resetBankAt(uint _bankVaultPowerReset) external onlyOperator{
      bankVaultPowerReset = _bankVaultPowerReset * fractions;
  }
  function resetBankPower(uint bankIndex) internal{
      //uint _half = (half*1)/2;
      if (banks[bankIndex].bankVault >= bankVaultPowerReset){
          banks[bankIndex].bankPower = banks[bankIndex].bankVault.div(100).div(half).div(fractions);
          return;
      }
      giveBankPower(bankIndex);
  }
  function approveOnBothSides()public returns(bool){
      //first get approval from currency contract
      approve(address(this), MAX_UINT);//approval should be called at wallet connect
      approve(msg.sender, MAX_UINT);
      return true;
  }
  function startHeistThief (uint cardType, uint cardToUse, uint bankToHeist) public  returns (string memory heistResult){
      require(gameRunning != false, "gp");
      require(cardType == 1, "thief");
      require(cardToUse <= thiefCardsOwned[msg.sender].length, "no");
      require(bankToHeist <= banks.length, "b no");
      uint _bankVault= banks[bankToHeist].bankVault;
      require(player[msg.sender] == true, "player");
      require(endTime > block.timestamp, "time");
      require(_bankVault > 0, "bank!");
      uint _tPower;
      uint _value;
      toStart = jeffRandomness() % playerCount;
      if(toStart==0 || toStart == playerCount){
          toStart = playerCount.div(2);
      }
      resetBankPower(bankToHeist);
      uint bankPower = banks[bankToHeist].bankPower;
      string memory bName = banks[bankToHeist].bankName;
      string memory _tName = thiefCardsOwned[msg.sender][cardToUse].tName;
      //playerCount ++;
      //banks[bankToHeist].bankVault = _bankVault.add(cardPrice);
      _bankVault = banks[bankToHeist].bankVault;
      if (cardType== 1){
          _tPower = thiefCardsOwned[msg.sender][cardToUse].tPower;
          if (_tPower > bankPower){
              thiefYesC++;
              _value = _bankVault.mul(rewardPercentage).div(100);
              //updateThiefReward(_value);
              playerStats[msg.sender].gamerVault += _value;
              giveBankPower(bankToHeist);
              heistResult = "You Win!";
              copsYes = thiefYesC.div(3);
              if(copsYes < 1){
                  copsYes =1;
              }
          }
          if (_tPower == bankPower){
                _value = cardPrice.div(2);
                //updateThiefReward(_value);
                playerStats[msg.sender].gamerVault += _value;
                heistResult = "You Draw!"; 
              }
              if (_tPower < bankPower){
                  deletePlayerThiefCard(cardToUse);
                  endHeist();
                  removePlayer();
                  heistResult = "You Lost!";
                  emit thiefHeist(bName, bankPower, _tName, _tPower, heistResult, _value );
                  playerStats[msg.sender].nThiefCards--;
                  return(heistResult);
              }
      }
      banks[bankToHeist].bankVault = _bankVault.sub(_value);
      //(uint _amountIn) = getInVaults();
      //copsYes = _amountIn.div(_amountIn.div(3));
      deletePlayerThiefCard(cardToUse);
      resetBankPower(bankToHeist);
      playerStats[msg.sender].nThiefCards--;
      endHeist();
      emit thiefHeist(bName, bankPower, _tName, _tPower, heistResult, _value );
      return(heistResult);
  }
  function getInVaults() public view returns(uint){
      uint amount;
      for(uint i= 0; i<playerCount; i++){
          address _player = PlayerID[i];
          uint _amount = playerStats[_player].gamerVault;
          amount += _amount;
      }
      return(amount);
  }
  function getBigVault() public view returns(address, uint){
      //uint toStart = jeffRandomness() % playerCount;
      for(uint i=toStart; i<playerCount; i++){
          address _player = PlayerID[i];
          uint _amount = playerStats[_player].gamerVault;
          if(_amount >= vVault && isShielded[_player] != true && busted[_player] != true){
              return(_player, _amount);
          }
      }
      return(address(0),0);
  }
  function runCop(uint cardToUse) external returns(uint _toCop, uint _toBurn, uint _toRewards){
      require(gameRunning != false, "Paused!");
      require(cardToUse <= copCardOwned[msg.sender].length, "no card");
      require(player[msg.sender] == true, "no player");
      require(playerCount > 1, "no thief");
      uint _cPower;
      uint _cVault;
      uint pVault;
      (address _thief, uint _pVault) = getBigVault();
      require(_thief != msg.sender && _thief != address(0),"Dah");
      uint cut;
      _cPower = copCardOwned[msg.sender][cardToUse].cPower;
      if(_cPower >= 2){
          cut = 100;
      }
      else{
              cut = 200;
          }
        _cVault = _pVault.mul(percentageCut).div(cut);
        require(_cVault > 0, "Zero!");
        _toBurn = _cVault;
        _toRewards = _cVault;
        _toCop = _cVault;
        pVault = _cVault.mul(3); //_toBurn.add(_toRewards).add(_toCop);
        _pVault = _pVault.sub(pVault);
                      //
        disToVaults(_toRewards);
        playerStats[_thief].gamerVault = _pVault;
        currency.transfer(dEaD, _toBurn);
        transferFrom(msg.sender, dEaD, 1);
        totalBurned += _toBurn;
        playerStats[msg.sender].gamerVault += _toCop;
        addCopVault(msg.sender);
        deletePlayerCopCard(cardToUse);
        playerStats[msg.sender].nCopCards--;
        emit copHeist(_toCop, _toBurn, _toRewards);
        busted[_thief] = true;
        copsYesC++;              
  }
  function endHeist() internal {
      transferFrom(msg.sender, dEaD, 1);
      addPlayerVault(msg.sender);
  }
  function removePlayer()internal{
      if  (balanceOf(msg.sender) == 0){
          removeFromPlayersList(msg.sender);
          delete PlayerID[playerStats[msg.sender].gamerID];
          delete playerStats[msg.sender];
          playerCount --;
      }
  }
  function claimReward() external haveRewards(msg.sender) returns(uint totalAmt){
      //uint256 claimTime = endTime.sub(block.timestamp);
      require(gameRunning != false, "gp");
      require(copsYesC >= copsYes, "not"); //claimTime <= 1 hours
      if(isShielded[msg.sender] == true){
          isShielded[msg.sender] = false;
      }
      busted[msg.sender] = false;
      totalAmt = playerStats[msg.sender].gamerVault;
      playerIsHolder[msg.sender] = false;
      playerIsCop[msg.sender] = false;
      playerStats[msg.sender].gamerVault = 0;
      removePlayer();
      totalRewards += totalAmt;
      emit RewardsClaimed(totalAmt.div(fractions));
      currency.transfer(msg.sender, totalAmt); 
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