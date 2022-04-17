/**
 *Submitted for verification at BscScan.com on 2022-04-17
*/

pragma solidity ^0.8.10;
// SPDX-License-Identifier: Unlicensed

interface IERC165Item {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721Item is IERC165Item {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getCharacterBannedStatus(uint256 _tokenId) external view returns (bool);
    function getOnwerBannedStatus(address _owner) external view returns (bool);
    function getTokenInfo(uint256 _tokenId) external view  returns (uint256, uint256, uint256, uint256, uint256, uint256, bool);
}

interface IRandomApplicable {
    function random(uint256 max, uint256 bonusNonce) external view returns (uint256);
    function randomBetween(uint256 min, uint256 max, uint256 bonusNonce) external view returns (uint256);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getInfo(uint256 tokenId) external view returns (uint256 rare, uint256 exp, uint256 lvl, uint256 class, bool isHatched, uint256 stamina, uint256 levelMilestones);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function updateTimeTradable(uint256 _tokenId, uint256 _tradeableTime) external;
    function includeAllowForTrading(address account) external;
    function excludeAllowForTrading(address account) external;
    function getTimeTradable(uint256 _tokenId) external view  returns (uint256);
    function getCharacterBannedStatus(uint256 _tokenId) external view returns (bool);
    function getOnwerBannedStatus(address _owner) external view returns (bool);
    function updateIsOpen(uint256 _tokenId,bool status) external;
    function updateOnSale(uint256 _tokenId,bool status) external;
    function burn(uint256 _tokenId) external;
    function getBannerStatus(uint256 _tokenId) external view returns (bool);
    function evolve( address _to, uint256[] memory _values) external returns (uint256);
    function updateTimeTradeable( address _to, uint256[] memory _values) external returns (uint256);
    function getTokenInfo(uint256 _tokenId) external view  returns (uint256, uint256, uint256, uint256, uint256, uint256, bool);
    function hatch(uint256 _tokenId, uint256 _hatchTime) external;
}

interface IBep20Token {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

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
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgValue() internal view virtual returns (uint256 value) {
        return msg.value;
    }

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MinterNFT is Ownable {
	using SafeMath for uint256;

    // ############
    // Events
    // ############
    event Minted(
        address indexed owner,
        uint256 factor,
        uint256 indexed newNFT
    );

    event ListMinted(
        address indexed owner,
        uint256 indexed newNFT
    );

    event Opened(
        address indexed owner,
        uint256 indexed newNFT,
        uint256 factor,
        uint256 rare,
        uint256 pixel,
        uint256 level,
        uint256 energy,
        uint256 rank
    );

    IBep20Token public tokenContract;
    IERC721 public camera;
    IERC721Item public nftItem;
	mapping(uint256 => mapping(uint256 => uint256)) private _totalFeeByDay;
	mapping(uint256 => uint256) public totalNftByFactor;
	mapping(uint256 => uint256) public totalNftByCombo;

    IRandomApplicable private _randomApplicable;

    mapping(uint256 => uint256) public mintFee;
    mapping(uint256 => uint256) public comboMintFee;
    address public mintFeeAddress;
	uint256 public totalFee;

	bool public isMaintained = false;
    
    mapping(address => bool) private _authorizedAddresses;
    modifier checkIsMaintained() {
        require(!isMaintained);
		_;
    }

    uint256 private randomKey = 0;

    modifier onlyAuthorizedAccount() {
		require(_authorizedAddresses[msg.sender] || owner() == msg.sender);
		_;
	}

    modifier isNotContract() {
        require(checkIsNotCallFromContract());
		require(_isNotContract(msg.sender));
		_;
	}

    function _isNotContract(address _addr) internal view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size == 0);
    }

    function checkIsNotCallFromContract() internal view returns (bool){
	    if(msg.sender == tx.origin){
		    return true;
	    }else{
	        return false;
	    }
	}

	constructor(address _tokenContract, address randomApplicable, address _camera) {
		tokenContract = IBep20Token(_tokenContract);
		tokenContract.approve(address(this), 99999999999999_000000000000000000);

        camera = IERC721(_camera);

        mintFee[1] = 25000000000000000;
        mintFee[2] = 25000000000000000;
        mintFee[3] = 50000000000000000;
        mintFee[4] = 125000000000000000;
        mintFee[5] = 250000000000000000;

        comboMintFee[1] = 1000000000000000000;
        comboMintFee[2] = 400000000000000000;
        totalFee = 0;

        _randomApplicable = IRandomApplicable(randomApplicable);

        mintFeeAddress = _msgSender();
	}

    function reinit(address _tokenContract, address _camera) public onlyAuthorizedAccount{
        tokenContract = IBep20Token(_tokenContract);
		tokenContract.approve(address(this), 99999999999999_000000000000000000);
        camera = IERC721(_camera);
    }

    // function mint(uint256 nftType) payable public isNotContract {
    //     require(nftType >= 1 && nftType <= 5,"Factor disabled");
    //     require(mintFee[nftType] == _msgValue(), "Value sent must equal minter price");
    //     payable(mintFeeAddress).transfer(address(this).balance);
    //     randomKey = randomKey.add(1);
    //     uint256 _nftId = 0;
    //     _nftId = camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey, nftType));
    //     totalNftByFactor[nftType] = totalNftByFactor[nftType] + 1;
    //     // return _nftId;
    //     emit Minted(msg.sender, _nftId, nftType);
	// }

    function mint(uint256 nftType, uint256 quantity) payable public isNotContract {
        require(nftType >= 1 && nftType <= 5,"Factor disabled");
        require(mintFee[nftType]*quantity == _msgValue(), "Value sent must equal minter price");
        payable(mintFeeAddress).transfer(address(this).balance);
        uint256 _NFTId = 0;
        for (uint j; j < quantity; j++) {
            randomKey = randomKey.add(1);
            uint256 _nftId = camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(j), nftType));
            if (_NFTId == 0) {
                _NFTId = _nftId;
            }
            totalNftByFactor[nftType] = totalNftByFactor[nftType] + 1;
        }
        // return (_NFTId, quantity);
        emit ListMinted(msg.sender, _NFTId);
	}

    function mintCombo(uint256 comboType, uint256 quantity) payable public isNotContract {
        require(comboType >= 1 && comboType <= 2,"Combo disabled");
        require(comboMintFee[comboType]*quantity == _msgValue(), "Value sent must equal combo price");
        payable(mintFeeAddress).transfer(address(this).balance);
        uint256 _NFTId = 0;
        if (comboType == 1) {
            for (uint i; i < quantity; i++) {
                for (uint j; j < 5; j++) {
                    randomKey = randomKey.add(1);
                    uint256 _nftId = camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(j), 5));
                    if (_NFTId == 0) {
                        _NFTId = _nftId;
                    }
                    totalNftByFactor[5] = totalNftByFactor[5] + 1;
                }
                totalNftByCombo[1] = totalNftByCombo[1] + 1;
            }
        } else if (comboType == 2) {
            for (uint i; i < quantity; i++) {
                randomKey = randomKey.add(1);
                uint256 _nftId = camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(i), 2));
                if (_NFTId == 0) {
                    _NFTId = _nftId;
                }
                totalNftByFactor[2] = totalNftByFactor[2] + 1;

                randomKey = randomKey.add(1);
                camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(i), 3));
                totalNftByFactor[3] = totalNftByFactor[3] + 1;

                randomKey = randomKey.add(1);
                camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(i), 4));
                totalNftByFactor[4] = totalNftByFactor[4] + 1;

                randomKey = randomKey.add(1);
                camera.evolve(_msgSender(), _initCameraAllAttribute(randomKey.add(i), 5));
                totalNftByFactor[5] = totalNftByFactor[5] + 1;

                totalNftByCombo[2] = totalNftByCombo[2] + 1;
            }
        }
        // return (_NFTId, quantity);
        emit ListMinted(msg.sender, _NFTId);
	}

    function open(uint256 nftId) public isNotContract {
        camera.updateIsOpen(nftId, true);
        (uint256 factor, uint256 rare, uint256 pixel, uint256 level, uint256 energy, uint256 rank, bool isOpen) = camera.getTokenInfo(nftId);
        // return nftId;
        emit Opened(msg.sender, nftId, factor, rare, pixel, level, energy, rank);
	}

    function checkMintable(address owner, uint256 factor) public view returns (bool mintableStatus, uint256 mintableCode){
        return _checkMintable(owner, factor);
	}

    function getMintFee(uint256 factor) public view returns (uint256 _mintFee){
        return mintFee[factor];
	}

    function getComboMintFee(uint256 combo) public view returns (uint256 _comboMintFee){
        return comboMintFee[combo];
	}

    //  1	Not enough token
    function _checkMintable(address owner, uint256 factor) internal view returns (bool, uint256){
        if(owner.balance >= mintFee[factor])
            return(true, 0);
        else
            return(false, 1);
	}

    function _initCameraAllAttribute(uint256 _randomKey, uint256 _factor) internal view returns (uint256[] memory){
        // uint256 scoreRank = _randomApplicable.randomBetween(1, 10000, _randomKey);
        uint256 factor = _factor;
        uint256 rare = _randomApplicable.randomBetween(1, 8, _randomKey);
        uint256 rank = 0;
        uint256 pixel = 0;
        uint256 level = 1;
        uint256 energy = 100;

        if (factor == 2) {
            rank = _randomApplicable.randomBetween(1, 3, _randomKey);
            pixel = _randomApplicable.randomBetween(0, 30, _randomKey);
        } else if (factor == 3) {
            rank = _randomApplicable.randomBetween(3, 5, _randomKey);
            pixel = _randomApplicable.randomBetween(30, 60, _randomKey);
        } else if (factor == 4) {
            rank = _randomApplicable.randomBetween(5, 7, _randomKey);
            pixel = _randomApplicable.randomBetween(60, 90, _randomKey);
        } else if (factor == 5) {
            rank = 7;
            pixel = _randomApplicable.randomBetween(80, 100, _randomKey);
        } else {
            rank = _randomApplicable.randomBetween(1, 8, _randomKey);
            pixel = _randomApplicable.randomBetween(1, 100, _randomKey);
        }

        uint256[] memory nftInit = new uint256[](6);
		nftInit[0] = factor;
		nftInit[1] = rare;
		nftInit[2] = pixel;
		nftInit[3] = level;
		nftInit[4] = energy;
		nftInit[5] = rank;

        return nftInit;
	}

    /*
	Admin update Permission user
	*/
	function grantPermission(address account) public onlyOwner {
		require(account != address(0));
		_authorizedAddresses[account] = true;
	}

	function revokePermission(address account) public onlyOwner {
		require(account != address(0));
		_authorizedAddresses[account] = false;
	}

    function updateMaintainedStatus(bool _isMaintained) public onlyOwner {
		isMaintained = _isMaintained;
	}

	function updateMintFee(address _mintFeeAddress, uint256 factor, uint256 _mintFee) public onlyAuthorizedAccount {
		mintFee[factor] = _mintFee;
        mintFeeAddress = _mintFeeAddress;
	}

	function updateComboMintFee(address _mintFeeAddress, uint256 combo, uint256 _comboMintFee) public onlyAuthorizedAccount {
		comboMintFee[combo] = _comboMintFee;
	}
}