/**
 *Submitted for verification at BscScan.com on 2023-02-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File contracts/library/Context.sol
// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File contracts/interface/IERC20.sol

pragma solidity ^0.8.10;


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}


// File contracts/library/Initializable.sol

pragma solidity ^0.8.0;
contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


// File contracts/dropzone.sol

pragma solidity ^0.8.0;



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function ownable(address _newowner) internal{
        _transferOwnership(_newowner);
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

contract Dropzone is Initializable, Ownable {

    struct Airdrop{
        address token;
        address owner;
        address[] particiepts;
        uint amount;
        uint distbutedAmount;
        uint from;
        uint to;
        bool isVesting;
        uint vestingPeriod;
        string[5] _socialMediaId;
        uint[5] _socialMediaAmount;
        uint _maxClaimableAmt;
        mapping(address=>ClaimWithVesting) claimWithVesting;
    }

    struct ClaimWithVesting{
        uint start;
        uint amount;
        uint end;
        uint checkpoint;
    }

    modifier onlyCreator(bytes32 _hash){
        require(airdrops[_hash].owner==msg.sender,"Airdrop : only Hash creator call");
        _;
    }

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
        
    event TimeUpdated(uint oldFrom ,uint oldTo , uint newFrom ,uint newTo);
    event AirdropListed(bytes32 indexed _hash,address indexed _token,address _owner , uint _amount, uint _from, uint _to ,bool _isVesting , uint _vestingPeriod);
    event AirdropClaimed(bytes32 indexed _hash,address token,address receiver,uint _amount); 
    bytes32 _EIP712_ORDER_SCHEMA_HASH = keccak256("Airdrop(address token,address owner,uint amount,uint from,uint to)");

    mapping(bytes32=>Airdrop) public airdrops;
    bytes32[] public allAirdrops;
    mapping(bytes32=>bool) public cancled;
    bool private locked;

    mapping(bytes32=>mapping(address=>uint)) private userclaimed;
    function initialize(address _newowner) external initializer {
        ownable(_newowner);
    }
   
    function applyforAirdrop(address _token,uint _amount,uint _from ,uint _to ,string[] memory _socialMedia ,uint[] calldata amount,bool _isVesting, uint _vestingPeriod) external  {
        require(_from<_to,"Invalid Date");
        // require(_to>block.timestamp && _from<=(block.timestamp),"Invalide from to timestamp");
        require(_socialMedia.length==amount.length,"Length not equal");
        require(IERC20(_token).allowance(msg.sender, address(this))>=_amount,"allowance exceed!");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        
        bytes32 _hash = getAirdropHash(_token, msg.sender, _amount, _from, _to);

        airdrops[_hash].token = _token;
        airdrops[_hash].owner = msg.sender;
        airdrops[_hash].amount = _amount;
        airdrops[_hash].from = _from;
        airdrops[_hash].to = _to;
        airdrops[_hash].isVesting = _isVesting;
        airdrops[_hash].vestingPeriod = _vestingPeriod;
        for(uint8 i=0; i< _socialMedia.length; i++){
            airdrops[_hash]._socialMediaAmount[i] = amount[i];
            airdrops[_hash]._socialMediaId[i] = _socialMedia[i];
            airdrops[_hash]._maxClaimableAmt+= amount[i];
        }
        allAirdrops.push(_hash);
        emit AirdropListed( _hash,_token, msg.sender, _amount,  _from, _to,_isVesting,_vestingPeriod);
    }

    function changeSocialMedia(bytes32 _hash,string[] calldata _socialMedia ,uint[] calldata amount) external onlyCreator(_hash) {
        require(!cancled[_hash],"Order is Cancled!");
        require(_socialMedia.length==amount.length,"Length not equal");
        airdrops[_hash]._maxClaimableAmt=0;
        for(uint8 i=0; i< _socialMedia.length; i++){
            airdrops[_hash]._socialMediaId[i] = _socialMedia[i];
            airdrops[_hash]._socialMediaAmount[i] = amount[i];
            airdrops[_hash]._maxClaimableAmt+= amount[i];
        }

    }

    function increaseAmount(bytes32 _hash,uint amount) external onlyCreator(_hash) {
        require(!cancled[_hash],"Order is Cancled!");
        require(IERC20(airdrops[_hash].token).allowance(msg.sender, address(this))>=amount,"allowance exceed!");
        IERC20(airdrops[_hash].token).transferFrom(msg.sender, address(this),amount);
        airdrops[_hash].amount+=amount;

    }

    function decreaseAmount(bytes32 _hash,uint amount) external onlyCreator(_hash) {
        require(!cancled[_hash],"Order is Cancled!");
        airdrops[_hash].amount-=amount;
        IERC20(airdrops[_hash].token).transfer(airdrops[_hash].owner, amount);
        
    }

    function updateTime(bytes32 _hash ,uint _newFrom ,uint _newTo) external onlyCreator(_hash){
        require(!cancled[_hash],"Order is Cancled!");
        require(_newFrom<_newTo ,"Invalid Time");
        emit TimeUpdated(airdrops[_hash].from , airdrops[_hash].to ,  _newFrom , _newTo);
        airdrops[_hash].from = _newFrom;
        airdrops[_hash].to = _newTo;
    

    }  
    
    function getAirdropHash(address _token, address _owner ,uint256 _amount, uint256 _from, uint _to) internal view returns (bytes32 orderHash) {
        orderHash = keccak256(abi.encode(_EIP712_ORDER_SCHEMA_HASH, _token, _owner, _amount, _from, _to));   
    }


    function getVestingTokenByUser(bytes32 _hash, address _user) public view returns(uint) {
        Airdrop storage airdrop = airdrops[_hash];
        ClaimWithVesting storage _claimWithVesting= airdrop.claimWithVesting[_user];

        uint256 totalAmount;
        uint256 finish = _claimWithVesting.end;
        if (_claimWithVesting.checkpoint < finish) {
            uint256 share = _claimWithVesting.amount;
            uint256 from = _claimWithVesting.start > _claimWithVesting.checkpoint ? _claimWithVesting.start : _claimWithVesting.checkpoint;
            uint256 to = finish < block.timestamp ? finish : block.timestamp;
            if (from < to) {
                totalAmount = totalAmount+(share*(to-from))/airdrop.vestingPeriod;
            }
        }

    return totalAmount;

    }

    function claimAirdrop(bytes32 _hash , uint _amount) external noReentrant {
        Airdrop storage airdrop = airdrops[_hash];
        require(!cancled[_hash],"Cancled");
        require((airdrop.amount-airdrop.distbutedAmount)>_amount,"Airdrop : Liqudity problem");
        uint claim =airdrop._maxClaimableAmt;
        require(claim>=_amount,"airdrop claim too high amount");
        if(!airdrop.isVesting){
            require(airdrop.from<block.timestamp && airdrop.to>block.timestamp,"Airdrop : Expired");
            require(userclaimed[_hash][msg.sender]==0,"already Claimed");
            IERC20(airdrop.token).transfer(msg.sender, _amount);
            userclaimed[_hash][msg.sender] =_amount;
            airdrops[_hash].distbutedAmount += _amount;
            airdrops[_hash].particiepts.push(msg.sender);
            emit AirdropClaimed(_hash,airdrop.token,msg.sender,_amount); 
        } else {
            if(userclaimed[_hash][msg.sender]!=0){
                require(airdrop.from<block.timestamp && airdrop.to>block.timestamp,"Airdrop : Expired");
                uint claimAMt = getVestingTokenByUser(_hash,msg.sender);
                airdrops[_hash].distbutedAmount += claimAMt;
                airdrops[_hash].claimWithVesting[msg.sender].checkpoint =block.timestamp;
                IERC20(airdrop.token).transfer(msg.sender, claimAMt);
            } else {
                userclaimed[_hash][msg.sender] =_amount;
                airdrops[_hash].claimWithVesting[msg.sender].start = block.timestamp;
                airdrops[_hash].claimWithVesting[msg.sender].end = block.timestamp+airdrop.vestingPeriod;
                airdrops[_hash].claimWithVesting[msg.sender].amount = _amount;
                airdrops[_hash].particiepts.push(msg.sender);
            }
        }
    }

    function allAirdropLenght() external view returns(uint) {
        return allAirdrops.length;
    }

    function getAllParticieptsLength(bytes32 _hash) external view returns(uint) {
        return airdrops[_hash].particiepts.length;
    }

    function getAllParticiepts(bytes32 _hash) external view returns (address[] memory) {
            return airdrops[_hash].particiepts;
    }
    
    function isAlreadyClaimed(bytes32 _hash ,address _user) external view returns(uint) {
        return userclaimed[_hash][_user];
    }

    function getSocialMediaReward(bytes32 _hash,uint8 _index)  external view returns(string memory socialMediaId,uint _amount) {
        return (airdrops[_hash]._socialMediaId[_index],airdrops[_hash]._socialMediaAmount[_index]);
    }
    
     
}