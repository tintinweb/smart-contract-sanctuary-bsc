/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: loterio.sol

//SPDX-License-Identifier: MIT

/*
                        ......,..                                               
                     .........,..........                                       
                       ....               ....                                  
                     ...                     ...                                
                   ...                          ...                             
                   ..                             ...                           
                   ..                               ...                         
                   ...                                ....                      
                   ...                                   ....                   
                   ...                                      ....                
                    ..                                ...........,              
                    ...                         .....,,.       .,,              
                    ...                   .....,,            .,,.               
                     ..               ....,,               ,,,                  
                     ...          ...,,.    .......    .,,,                     
                     ...      ...,,     ..          ..,.                        
                     ...   ...,,       ..             .,                        
                     ......,.         ..              ..,                       
                      ...,           ...             ..,.                       
                      ..,   ..,,,,,,..  ...        ...*                         
                                          *.......**.                                     
    
    Loterio v1.0
*/
pragma solidity ^0.8.0;


contract loterio is Ownable {

    uint256 private price;
    uint256 private period;
    uint8 private potRatio;
    uint8 private startRatio;
    uint8 private endRatio;
    uint8 private initRatio;

    mapping(uint256 => bool) private status;
    mapping(uint256 => uint256) private pot;
    mapping(uint256 => uint256) private startIncentive;
    mapping(uint256 => address) private starter;
    mapping(uint256 => uint256) private initPot;
    mapping(uint256 => uint256) private endIncentive;
    mapping(uint256 => address) private finisher;
    mapping(address => uint256) private rewards;
    mapping(uint256 => uint256) private totalEntries;
    mapping(uint256 => uint256) private startDate;
    mapping(uint256 => uint256) private endDate;
    mapping(uint256 => address) private winner;
    mapping(uint256 => mapping(uint256 => address)) private entries;
    mapping(uint256 => mapping(address => uint256)) private participant;

    uint256 private id = 0;
    uint256 private entry = 0;
    uint256 private claimRemaining = 0;
    bool private maintenance = false;

    event Start(uint256 indexed id, address indexed starter, uint256 startIncentive);
    event Participation(uint256 indexed id, address indexed participant, uint256 entry, uint256 entries);
    event End(uint256 indexed id, address indexed winner, uint256 entry, uint256 prize, address indexed finisher, uint256 endIncentive);
    event Claim(address indexed claimer, uint256 amount);

    constructor(uint256 _price, uint8 _potRatio, uint8 _startRatio, uint8 _endRatio, uint8 _initRatio, uint256 _period) {
        price = _price;
        potRatio = _potRatio;
        startRatio = _startRatio;
        endRatio = _endRatio;
        initRatio = _initRatio;
        period = _period;
    }

    //Main

    function start() external payable notActive {
        require(!maintenance, "Mintenance in progress");

        pot[id] += initPot[id];
        pot[id] += msg.value;
        status[id] = true;
        startDate[id] = block.timestamp;
        starter[id] = msg.sender;
        rewards[msg.sender] += startIncentive[id];
        claimRemaining += startIncentive[id];

        emit Start(id, msg.sender, startIncentive[id]);
    }

    function participate() external payable active {
        require(msg.value >= price, "Invalid entry price");

        participant[id][msg.sender]++;
        entries[id][entry] = msg.sender;
        totalEntries[id]++;
        pot[id] += (msg.value * potRatio) / 100;
        endIncentive[id] += (msg.value * endRatio) / 100;
        startIncentive[id + 1] += (msg.value * startRatio) / 100;
        initPot[id + 1] += (msg.value * initRatio) / 100;

        emit Participation(id, msg.sender, entry, participant[id][msg.sender]);

        entry++;
    }

    function end() external active {
        require(block.timestamp - startDate[id] > period, "Still in progress");

        if(totalEntries[id] != 0) {
            uint256 _number = randNumber(totalEntries[id]);
            address _winner = entries[id][_number];
            winner[id] = _winner;
            rewards[_winner] += pot[id];
            rewards[msg.sender] += endIncentive[id];
            claimRemaining += pot[id] + endIncentive[id];
            status[id] = false;
            endDate[id] = block.timestamp;
            finisher[id] = msg.sender;

            emit End(id, _winner, _number, pot[id], msg.sender, endIncentive[id]);
        } else {
            emit End(id, address(this), 0, pot[id], msg.sender, endIncentive[id]);
        }

        entry = 0;
        id++;
    }

    function claim() external {
        require(rewards[msg.sender] > 0, "Nothing to claim");
        require(address(this).balance >= rewards[msg.sender], "Not enough balance");

        payable(msg.sender).transfer(rewards[msg.sender]);

        emit Claim(msg.sender, rewards[msg.sender]);

        claimRemaining -= rewards[msg.sender];
        rewards[msg.sender] = 0;

    }

    function withdraw() external onlyOwner notActive {
        require(address(this).balance - claimRemaining > 0, "Nothing to withdraw");

        payable(msg.sender).transfer(address(this).balance - claimRemaining);
    }

    //Utils

    function randNumber(uint256 _maxNumber) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % _maxNumber;
    }

    //Status

    function checkMaintenance() public view returns (bool) {
        return maintenance;
    }

    function checkStatus() public view returns (bool) {
        return status[id];
    }

    function checkEnd() public view returns (bool) {
        return status[id] && block.timestamp - startDate[id] > period;
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }

    //Setters

    function setPrice(uint256 _amount) external onlyOwner notActive {
        price = _amount;
    }

    function setPeriod(uint256 _seconds) external onlyOwner notActive {
        period = _seconds;
    }

    function setMaintenance(bool _stat) external onlyOwner {
        maintenance = _stat;
    }

    function setPotRatio(uint8 _ratio) external onlyOwner notActive {
        require(_ratio >= 0 && _ratio <= 100, "Ratio out of range (0 to 100)");
        require(_ratio + startRatio + endRatio + initRatio <= 100, "Exceeded ratio");

        potRatio = _ratio;
    }

    function setStartRatio(uint8 _ratio) external onlyOwner notActive {
        require(_ratio >= 0 && _ratio <= 100, "Ratio out of range (0 to 100)");
        require(potRatio + _ratio + endRatio + initRatio <= 100, "Exceeded ratio");

        startRatio = _ratio;
    }

    function setEndRatio(uint8 _ratio) external onlyOwner notActive {
        require(_ratio >= 0 && _ratio <= 100, "Ratio out of range (0 to 100)");
        require(potRatio + startRatio + _ratio + initRatio <= 100, "Exceeded ratio");

        endRatio = _ratio;
    }

    function setInitRatio(uint8 _ratio) external onlyOwner notActive {
        require(_ratio >= 0 && _ratio <= 100, "Ratio out of range (0 to 100)");
        require(potRatio + startRatio + endRatio + _ratio <= 100, "Exceeded ratio");

        initRatio = _ratio;
    }

    //Getters

    function getId() public view returns (uint256) {
    return id;
    }

    function getPrice() public view returns (uint256) {
        return price;
    }

    function getPotRatio() public view returns (uint256) {
        return potRatio;
    }

    function getStartRatio() public view returns (uint256) {
        return startRatio;
    }

    function getEndRatio() public view returns (uint256) {
        return endRatio;
    }

    function getInitRatio() public view returns (uint256) {
        return initRatio;
    }

    function getPeriod() public view returns (uint256) {
        return period;
    }

    function getPot(uint256 _id) public view returns (uint256) {
    return pot[_id];
    }

    function getEntries(uint256 _id, address _address) public view returns (uint256) {
        return participant[_id][_address];
    }

    function getTotalEntries(uint256 _id) public view returns (uint256) {
        return totalEntries[_id];
    }

    function getWinner(uint256 _id) public view returns (address) {
        return winner[_id];
    }

    function getStartDate(uint256 _id) public view returns (uint256) {
        return startDate[_id];
    }

    function getEndDate(uint256 _id) public view returns (uint256) {
        return endDate[_id];
    }

    function getStartIncentive(uint256 _id) public view returns (uint256) {
        return startIncentive[_id];
    }

    function getEndIncentive(uint256 _id) public view returns (uint256) {
        return endIncentive[_id];
    }

    function getInitPot(uint256 _id) public view returns (uint256) {
        return initPot[_id];
    }

    function getStarter(uint256 _id) public view returns (address) { 
        return starter[_id];
    }

    function getFinisher(uint256 _id) public view returns (address) {
        return finisher[_id];
    }

    function getClaimable(address _address) public view returns (uint256) {
        return rewards[_address];
    }

    //Adders

    function addPot(uint256 _id) external payable {
        require(_id >= id, "Lottery already over");
        pot[_id] += msg.value;
    }

    function addInitPot(uint256 _id) external payable {
        require(_id > id || (_id == id && !status[id]), "Lottery already over or in process");
        initPot[_id] += msg.value;
    }

    function addStartIncentive(uint256 _id) external payable {
        require(_id > id || (_id == id && !status[id]), "Lottery already over or in process");
        startIncentive[_id] += msg.value;
    }

    function addEndIncentive(uint256 _id) external payable {
        require(_id >= id, "Lottery already over");
        endIncentive[_id] += msg.value;
    }

    function addBalance() external payable {
        //Thanks!
    }

    //Modifiers

    modifier notActive {
      require(!status[id], "Lottery in process");
      _;
    }

    modifier active {
      require(status[id], "No lottery in process");
      _;
    }

}