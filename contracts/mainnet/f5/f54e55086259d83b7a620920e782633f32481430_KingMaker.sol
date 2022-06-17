/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// KingMaker Beta 2

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
abstract contract Ownable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library EnumerableSet {

    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }


    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

contract KingMaker is Ownable {
    
    IERC20 public immutable knightToken = IERC20(address(0x16C0e0936E1B38Ff1F9b8a1e75d8ba29aDf87d30));
    IERC20 public immutable nftBoost = IERC20(address(0xf812C8D2433B110d9bec52c3425fA90f1bD76d47));
    IERC20 public immutable knightBnbLPToken = IERC20(address(0x8e53470B95d52A3D83637BF9E42891b17E785Ba4));

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private playerList;

    mapping (address => uint256) private peasants;
    mapping (address => uint256) private farmers;
    mapping (address => uint256) private knights;
    mapping (address => uint256) private nobles;
    mapping (address => uint256) private kings;
    
    mapping (address => uint256) public startTime;
    mapping (address => uint256) public lastUpdateTime;
    mapping (address => uint256) public highScore;
    
    uint256 public farmerCost = 100;
    uint256 public knightCost = 10000;
    uint256 public nobleCost = 1000000;
    uint256 public kingCost = 100000000;
    uint256 public fakeMultiplier =  2000 * 1e18;

    bool public isTest;
    
    bool internal updating;
    
    mapping (uint256 => address) private leaderboard;

    constructor (bool _isTest) {
        isTest = _isTest;
    }
    
    function getHolderKnightBalance(address holder) public view returns (uint256){
        return knightToken.balanceOf(holder);
    }
    
    function getHolderNFTBalance(address holder) public view returns (uint256){
        return nftBoost.balanceOf(holder);
    }
    
    function getHolderKnightLPBalance(address holder) public view returns (uint256){
        return knightBnbLPToken.balanceOf(holder);
    }
    
    function getMultiplier(address holder) public view returns (uint256){
        if(isTest){
            return fakeMultiplier;
        }
        uint256 holderBalance = getHolderKnightBalance(holder);
        uint256 holderNFTBalance = getHolderNFTBalance(holder);
        uint256 holderLPBalance = getHolderKnightLPBalance(holder);
        uint256 multiplier = (holderBalance / 100000)+1e18; // multiplier is +1x for every 100000 KNIGHT held.
        multiplier = multiplier + ((holderNFTBalance * 1e18 / 5)); // multiplier is +1x for every 5 NFTs held.
        multiplier = multiplier + ((holderLPBalance/ 50)); // multiplier is +1x for every 50 Knight-BNB LPs held.
        if(multiplier > 2000 * 1e18){
            return 2000 * 1e18;
        }
        return multiplier;
    }
    
    function getMultiplierFromLP(address holder) public view returns (uint256){
        uint256 holderLPBalance = getHolderNFTBalance(holder);
        return (holderLPBalance/ 50); // multiplier is +1x for every 50 Knight-BNB LPs held.
    }
    
    function getMultiplierFromNFT(address holder) public view returns (uint256){
        uint256 holderNFTBalance = getHolderNFTBalance(holder);
        return ((holderNFTBalance * 1e18 / 5)); // multiplier is +1x for every 5 NFTs held.
    }
    
    function getMultiplierFromKnight(address holder) public view returns (uint256){
        uint256 holderBalance = getHolderKnightBalance(holder);
        return (holderBalance / 100000)+1e18; // multiplier is +1x for every 100000 KNIGHT held.
    }
    
    function getLastUpdateTime(address holder) public view returns (uint256){
        return lastUpdateTime[holder];
    }
    
    function getScore(address holder) public view returns (uint256){
        return (getPeasants(holder) + (getFarmers(holder) * farmerCost * 2) + (getKnights(holder) * farmerCost * knightCost * 3) + (getNobles(holder) * farmerCost * knightCost * nobleCost * 4) + (getKings(holder) * farmerCost * knightCost * nobleCost * kingCost * 5));
    }
    
    function startGame() public returns (bool){
        require(startTime[msg.sender] == 0, "May not restart game with this wallet");
        if(!isTest){
            require(getHolderKnightBalance(msg.sender) >= 1000 * 1e18, "Must hold at least 1000 KNIGHT to play");
        }
        playerList.add(msg.sender);
        startTime[msg.sender] = block.timestamp;
        lastUpdateTime[msg.sender] = block.timestamp;
        
        return true;
    }

    function getTimePassed(address holder) public view returns (uint256){
        return getLastUpdateTime(holder) <= block.timestamp ? block.timestamp - getLastUpdateTime(holder) : 0;
    }
    
    function getPeasants(address holder) public view returns (uint256){
        if(startTime[holder] == 0){return 0;}
        uint256 amountFromTime = getTimePassed(holder);
        return peasants[holder] + (((amountFromTime)*getMultiplier(holder))/1e18) + (getFarmers(holder)*amountFromTime);
    }
    
    function getFarmers(address holder) public view returns (uint256){
        if(startTime[holder] == 0){return 0;}
        uint256 amountFromTime = getTimePassed(holder);
        return farmers[holder] + (knights[holder]*amountFromTime*getMultiplier(holder))/1e18/10;
    }
    
    function getKnights(address holder) public view returns (uint256){
        if(startTime[holder] == 0){return 0;}
        uint256 amountFromTime = getTimePassed(holder);
        return knights[holder] + (nobles[holder]*amountFromTime*getMultiplier(holder))/1e18/100;
    }
    
    function getNobles(address holder) public view returns (uint256){
        if(startTime[holder] == 0){return 0;}
        uint256 amountFromTime = getTimePassed(holder);
        return nobles[holder] + (kings[holder]*amountFromTime*getMultiplier(holder))/1e18/1000;
    }
    
    function getKings(address holder) public view returns (uint256){
        if(startTime[holder] == 0){return 0;}
        return kings[holder];
    }
    
    function buyFarmers(uint256 number) public {
        require(number * farmerCost <= getPeasants(msg.sender), "Not enough peasants to buy this many farmers");
        if(number == 0){return;}
        updateUnits(msg.sender);
        peasants[msg.sender] -= number * farmerCost;
        farmers[msg.sender] += number;
        updateScore(msg.sender);
    }
    
    function buyMaxFarmers() public {
        buyFarmers(getPeasants(msg.sender) / farmerCost);
    }
    
    function buyKnights(uint256 number) public {
        require(number * knightCost <= getFarmers(msg.sender), "Not enough farmers to buy this many knights");
        if(number == 0){return;}
        updateUnits(msg.sender);
        farmers[msg.sender] -= number * knightCost;
        knights[msg.sender] += number;
        updateScore(msg.sender);
    }
    
    function buyMaxKnights() public {
        buyKnights(getFarmers(msg.sender) / knightCost);
    }
    
    function buyNobles(uint256 number) public {
        require(number * nobleCost <= getKnights(msg.sender), "Not enough knights to buy this many nobles");
        if(number == 0){return;}
        updateUnits(msg.sender);
        knights[msg.sender] -= number * nobleCost;
        nobles[msg.sender] += number;
        updateScore(msg.sender);
    }
    
    function buyMaxNobles() public {
        buyNobles(getKnights(msg.sender) / nobleCost);
    }
    
    function buyKings(uint256 number) public {
        require(number * kingCost <= getNobles(msg.sender), "Not enough nobles to buy this many kings");
        if(number == 0){return;}
        updateUnits(msg.sender);
        nobles[msg.sender] -= number * kingCost;
        kings[msg.sender] += number;
        updateScore(msg.sender);
    }
    
    function buyMaxKings() public {
        buyKings(getNobles(msg.sender) / kingCost);
    }
    
    function getAllScores() public view returns (address[] memory, uint256[] memory){

        address[] memory listOfPlayers = getAllPlayers();
        uint256[] memory scores = new uint256[](listOfPlayers.length);

        for(uint256 i = 0; i < listOfPlayers.length; i++){
            scores[i] = highScore[listOfPlayers[i]];
        }

        return (listOfPlayers, scores);
    }

    function getAccountRank(address wallet) public view returns (uint256, uint256){
        uint256 walletHighScore = highScore[wallet];
        uint256 walletRank = 1;
        uint256 ties = 0;
        (, uint256[] memory scores) = getAllScores();
        for(uint256 i = 0; i < scores.length; i++){
            if(scores[i] > walletHighScore){
                walletRank += 1;
            }
            if(scores[i] == walletHighScore){
                ties += 1;
            }
        }
        return (walletRank, ties);
    }

    function returnTop3Scores() external view returns (address[] memory, uint256[] memory){
        address[] memory top3Wallets = new address[](3);
        uint256[] memory scores = new uint256[](3);

        address[] memory listOfPlayers = getAllPlayers();

        for(uint256 i = 0; i < listOfPlayers.length; i++){
            (uint256 accountRank,) = getAccountRank(listOfPlayers[i]);
            if(accountRank == 1){
                top3Wallets[0] = listOfPlayers[i];
                scores[0] = highScore[listOfPlayers[i]];
            } else if(accountRank == 2) {
                top3Wallets[1] = listOfPlayers[i];
                scores[1] = highScore[listOfPlayers[i]];
            } else if(accountRank == 3) {
                top3Wallets[2] = listOfPlayers[i];
                scores[2] = highScore[listOfPlayers[i]];
            }
        }
        return (top3Wallets, scores);
    }

    function returnFullyOrderedLeaderboard() external view returns (address[] memory, uint256[] memory){


        address[] memory listOfPlayers = getAllPlayers();
        address[] memory wallets = new address[](listOfPlayers.length);
        uint256[] memory scores = new uint256[](listOfPlayers.length);
        uint256 accountRank;

        for(uint256 i = 0; i < listOfPlayers.length; i++){
            (accountRank,) = getAccountRank(listOfPlayers[i]);
            wallets[accountRank-1] = listOfPlayers[i];
            scores[accountRank-1] = highScore[listOfPlayers[i]];
        }
        return (wallets, scores);
    }



    function getAllPlayers() public view returns (address[] memory listOfPlayers){
        listOfPlayers = playerList.values();
    }
    
    function updateScore(address holder) private {
        if(getScore(holder) > highScore[holder]){ // should be based on high score not current score
            highScore[holder] = getScore(holder);
        }
    }
    
    function updateUnits(address holder) private {
        require(!updating, "May not re-enter during an update");
        updating = true;
        
        peasants[holder] = getPeasants(holder);
        farmers[holder] = getFarmers(holder);
        knights[holder] = getKnights(holder);
        nobles[holder] = getNobles(holder);
        kings[holder] = getKings(holder);
        
        lastUpdateTime[holder] = block.timestamp;
        
        updating = false;
    }
    
    function update() external {
        require(startTime[msg.sender] > 0, "must start game to update units");
        updateUnits(msg.sender);
        updateScore(msg.sender);
    }

    function buyMaxAll() external {
        buyMaxFarmers();
        buyMaxKnights();
        buyMaxNobles();
        buyMaxKings();
    }
}