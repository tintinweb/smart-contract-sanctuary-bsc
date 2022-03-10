/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ILandCore {
    function mintLandByPermission(address _owner, uint256[] calldata _landId) external;
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract Bundle is Ownable {

    event BuyLandLimitByAccount(address owner, uint256 amount, uint256 typeLand);
    event BuyLandPublicSale(address owner, uint256 amount, uint256 typeLand);
    event BuyLandGatcha(address owner, uint256 amount, uint256 typeLand);

    address public adminAddress;
    address public pvuAddress;
    address public landNftAddress;
    address public busdAddress = 0xD4302Cc6Dca1DD45d3AA3BaE90469a3C31E918b7;

    uint256 private nonce = 0;

    uint256 public landSizeMPrice = 2500 * 10 ** 18;
    uint256 public landSizeLPrice = 6000 * 10 ** 18;
    uint256 public landSizeXLPrice = 12500 * 10 ** 18;
    uint256 public landSizeXXLPrice = 25000 * 10 ** 18;

    uint256 public limitSizeM = 4;
    uint256 public limitSizeL = 3;
    uint256 public limitSizeXL = 2;
    uint256 public limitSizeXXL = 1;

    mapping(uint256 => uint256[]) public lands;
    mapping(uint256 => uint256[]) public landPublic;
    mapping(uint256 => uint256[]) public landGatcha;
    mapping(uint256 => uint256) public landPublicPrice;
    mapping(uint256 => uint256) public landGachaPrice;
  
    struct Limit {
        uint256 M;
        uint256 L;
        uint256 XL;
        uint256 XXL;
    }

    mapping(address => Limit) public limitAccount;

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "NOT_THE_ADMIN");
        _;
    }

    function updateLandSizeMPrice(uint256 _price) external onlyAdmin {
        landSizeMPrice = _price;
    }

    function updateLandSizeLPrice(uint256 _price) external onlyAdmin {
        landSizeLPrice = _price;
    }

    function updateLandSizeXLPrice(uint256 _price) external onlyAdmin {
        landSizeXLPrice = _price;
    }

    function updateLandSizeXXLPrice(uint256 _price) external onlyAdmin {
        landSizeXXLPrice = _price;
    }

    function updateLimitSizeM(uint256 _limit) external onlyAdmin {
        limitSizeM = _limit;
    }

    function updateLimitSizeL(uint256 _limit) external onlyAdmin {
        limitSizeL = _limit;
    }

    function updateLimitSizeXL(uint256 _limit) external onlyAdmin {
        limitSizeXL = _limit;
    }

    function updateLimitSizeXXL(uint256 _limit) external onlyAdmin {
        limitSizeXXL = _limit;
    }

    function updatePricePublicLand(uint256 _type, uint256 _price) external onlyAdmin {
        landPublicPrice[_type] = _price;
    }

    function updatePriceGatchaLand(uint256 _type, uint256 _price) external onlyAdmin {
        landGachaPrice[_type] = _price;
    }

    function getLandLength(uint256 _type) external view returns(uint256){
        return lands[_type].length;
    }
    
    function getLand(uint256 _type) external view returns(uint256[] memory){
        return lands[_type];
    }
    
    function addLandId(uint256 _type, uint256[] calldata _landIds) external onlyAdmin {
        for(uint i=0; i<_landIds.length; i++) {
            lands[_type].push(_landIds[i]);
        }
    }

    function deleteLand(uint256 _type) external onlyAdmin {
        delete lands[_type];
    }

    function getLandPublicLength(uint256 _type) external view returns(uint256){
        return landPublic[_type].length;
    }
    
    function getLandPublic(uint256 _type) external view returns(uint256[] memory){
        return landPublic[_type];
    }
    
    function addLandPublicId(uint256 _type, uint256[] calldata _landIds) external onlyAdmin {
        for(uint i=0; i<_landIds.length; i++) {
            landPublic[_type].push(_landIds[i]);
        }
    }

    function deleteLandPublic(uint256 _type) external onlyAdmin {
        delete landPublic[_type];
    }

    function getLandGatchaLength(uint256 _type) external view returns(uint256){
        return landGatcha[_type].length;
    }
    
    function getLandGatcha(uint256 _type) external view returns(uint256[] memory){
        return landGatcha[_type];
    }
    
    function addLandGatchaId(uint256 _type, uint256[] calldata _landIds) external onlyAdmin {
        for(uint i=0; i<_landIds.length; i++) {
            landGatcha[_type].push(_landIds[i]);
        }
    }

    function deleteLandGatcha(uint256 _type) external onlyAdmin {
        delete landGatcha[_type];
    }

    function buyLandSizeM(uint256 _amount) external {
        require(limitAccount[msg.sender].M < limitSizeM, "LIMIT LAND SIZE M");
        require(_amount >= landSizeMPrice, "INVALID AMOUNT SizeM");
        require(IERC20(pvuAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandIndex(0);
        landId[0] = lands[0][index];  
        _removeLand(0, index);  
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandLimitByAccount(msg.sender, _amount, 0);
        limitAccount[msg.sender].M +=1;
    }

    function buyLandSizeL(uint256 _amount) external {
        require(limitAccount[msg.sender].L < limitSizeL, "LIMIT LAND SIZE L");
        require(_amount >= landSizeLPrice, "INVALID AMOUNT SizeL");
        require(IERC20(pvuAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandIndex(1);
        landId[0] = lands[1][index];  
        _removeLand(1, index);  
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandLimitByAccount(msg.sender, _amount, 1);
        limitAccount[msg.sender].L +=1;
    }

    function buyLandSizeXL(uint256 _amount) external {
        require(limitAccount[msg.sender].XL < limitSizeXL, "LIMIT LAND SIZE XL");
        require(_amount >= landSizeXLPrice, "INVALID AMOUNT SizeXL");
        require(IERC20(pvuAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandIndex(2);
        landId[0] = lands[2][index];
        _removeLand(2, index);  
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandLimitByAccount(msg.sender, _amount, 2);
        limitAccount[msg.sender].XL +=1;
    }

    function buyLandSizeXXL(uint256 _amount) external {
        require(limitAccount[msg.sender].XXL < limitSizeXXL, "LIMIT LAND SIZE XXL");
        require(_amount >= landSizeXXLPrice, "INVALID AMOUNT SizeXXL");
        require(IERC20(pvuAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandIndex(3);
        landId[0] = lands[3][index];  
        _removeLand(3, index);  
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandLimitByAccount(msg.sender, _amount, 3);
        limitAccount[msg.sender].XXL +=1;
    }

    function buyLandPublicSale(uint256 _type, uint256 _amount) external {
        require(_amount >= landPublicPrice[_type], "INVALID AMOUNT");
        require(IERC20(busdAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandPublicIndex(_type);
        landId[0] = landPublic[_type][index];  
        _removeLandPublic(_type, index);
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandPublicSale(msg.sender, _amount, _type);
    }

    function buyLandGacha(uint256 _type, uint256 _amount) external {
        require(_amount >= landGachaPrice[_type], "INVALID AMOUNT");
        require(IERC20(busdAddress).transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");
        uint256[] memory landId = new uint256[](1);
        uint256 index = _randomLandGatchaIndex(_type);
        landId[0] = landGatcha[_type][index];  
        _removeLandGatcha(_type, index);
        ILandCore(landNftAddress).mintLandByPermission(msg.sender, landId);
        emit BuyLandGatcha(msg.sender, _amount, _type);
    }

    function _randomLandIndex(uint256 _type) private returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % (lands[_type].length);
        nonce++;
        
        return index;
    }

    function _randomLandPublicIndex(uint256 _type) private returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % (landPublic[_type].length);
        nonce++;
        
        return index;
    }

    function _randomLandGatchaIndex(uint256 _type) private returns (uint256) {
        uint256 randomN = uint256(blockhash(block.number));
        uint256 index = uint256(keccak256(abi.encodePacked(randomN, block.timestamp, nonce))) % (landGatcha[_type].length);
        nonce++;
        
        return index;
    }

    function _removeLand(uint256 _type,uint256 _index) private {
        if (_index >= lands[_type].length) return;
        lands[_type][_index] = lands[_type][lands[_type].length-1];
        lands[_type].pop();
    }

    function _removeLandPublic(uint256 _type,uint256 _index) private {
        if (_index >= landPublic[_type].length) return;
        landPublic[_type][_index] = landPublic[_type][landPublic[_type].length-1];
        landPublic[_type].pop();
    }

    function _removeLandGatcha(uint256 _type,uint256 _index) private {
        if (_index >= landGatcha[_type].length) return;
        landGatcha[_type][_index] = landGatcha[_type][landGatcha[_type].length-1];
        landGatcha[_type].pop();
    }

    // @dev Sets the reference to the admin.
    /// @param _address - Address of admin.
    function setAdminAddress(address _address) external onlyOwner {
        adminAddress = _address;
    }

    // @dev Sets the reference to the land nft.
    /// @param _address - Address of land nft contract.
    function setLandNftAddress(address _address) external onlyAdmin {
        landNftAddress = _address;
    }

    function getBalance(address _token) public view returns(uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function withdrawBalance(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(owner(), _amount);
    }

    function setBusdAddress(address _token) external onlyOwner {
        busdAddress = _token;
    }

    function setPVUAddress(address _token) external onlyOwner {
        pvuAddress = _token;
    }
}