// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

import './interface/IPool.sol';
import './interface/IChaChaNodePool.sol';
import './interface/IChaChaDao.sol';
import './interface/IChaCha.sol';
import './interface/IERC20.sol';
import './libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChaChaNodePool is IPool,IChaChaNodePool,Ownable{

    address private daoAddress;

    mapping(address => uint256) private claimTime;

    uint256 private startTime = 1645747200;


    address private chachaToken;

    uint256 public fee;

    address public feeAddress;

    event Claim(address indexed user,  uint256 amount);

    event Mint(address indexed user,  uint256 amount);

    event Burn(address indexed user,  uint256 amount);

    event FeeChange(uint256 fee,address  feeAddress);

    constructor(address _daoAddress,address _chachaToken){
        require(_daoAddress != address(0) && _chachaToken != address(0),"daoAddress or chachaToken is not zero address require");
        daoAddress = _daoAddress;
        chachaToken = _chachaToken;
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyMinter() {
        require(IChaChaDao(daoAddress).isMinter(msg.sender), "Ownable: caller is not the MinterAddress");
        _;
    }

    function setFee(uint256 _fee,address _feeAddress) external override returns (bool){
        require(msg.sender == daoAddress, "Ownable: caller is not the DaoAddress");
        fee = _fee;
        feeAddress = _feeAddress;
        emit FeeChange(_fee,_feeAddress);
        return true;
    }



    function mint(address account, uint256 amount)
        external
        override
        onlyMinter
        returns (bool){
            if(IERC20(chachaToken).balanceOf(address(this)) < amount){
                IChaCha(chachaToken).mint(); // CHACHA issue function。 
            }
        require(IERC20(chachaToken).balanceOf(address(this)) >= amount, "NFT mint may be end");
        TransferHelper.safeTransfer(chachaToken, account, amount);
        emit Mint(account,amount);
        return true;
    }

    function burn(uint256 amount)
        external
        onlyMinter
        returns (bool){
            if(IERC20(chachaToken).balanceOf(address(this)) < amount){
                IChaCha(chachaToken).mint();
            }
        require(IERC20(chachaToken).balanceOf(address(this)) >= amount, "Burn error");
        TransferHelper.safeTransfer(chachaToken, address(0), amount);
        emit Burn(address(0),amount);
        return true;

    }

    function claim() payable
        external
        returns (bool){
        require(msg.value >= fee);
        require(fee != 0 && feeAddress != address(0));
        uint256 lastTime = (((block.timestamp - startTime)/ 1 days)) * 1 days + startTime;
        require(claimTime[msg.sender] == 0 || claimTime[msg.sender] <= lastTime);
        claimTime[msg.sender] = block.timestamp;
        TransferHelper.safeTransferETH(feeAddress, msg.value);
        emit Claim(msg.sender,msg.value);
        return true;
    }
    function withdrawETH() public onlyOwner{
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    } 
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IPool{
     function mint(address account, uint256 amount)
        external
        returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;
interface IChaChaNodePool{
    function setFee(uint256 fee,address feeAddress) external  returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IChaChaDao {
    function getChaCha() external view returns (address);
    function lpRate() external view returns (uint256);
    function nftRate() external view returns (uint256);
    function nodeRate() external view returns (uint256);
    function protocolRate() external view returns (uint256);
    function lpPool() external view returns(address);
    function nftPool() external view returns(address);
    function nodePool() external view returns(address);
    function protocolAddress() external view returns(address);
    function boxAddress() external view returns(address);
    function isPool(address pool) external view returns(bool);
    function isMinter(address minter) external view returns(bool);
    function setMinter(address minter,bool isMinter) external  returns(bool);
    function setLpRate(uint256 lpRate) external returns (uint256);
    function setNodeRate(uint256 nodeRate) external returns (uint256);
    function setNftRate(uint256 nftRate) external returns (uint256);
    function setProtocolRate(uint256 protocolRate) external returns (uint256);
    function setChachaToken(address chachaToken) external returns (address);
    function setLpPool(address lpPool) external returns (address);
    function setNftPool(address nftPool) external returns (address);
    function setNodePool(address nodePool) external returns (address);
    function setProtocolAddress(address protocolAddress) external returns (address);
    function setBoxAddress(address boxAddress) external returns (address);

}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.0;

import './IChaChaLP.sol'; 
import './IChaChaNFT.sol'; 
import './IChaChaNode.sol';
import './IChaChaSwitch.sol';

interface IChaCha is IChaChaLP,IChaChaNFT,IChaChaNode,IChaChaSwitch{
     function mint()
        external
        returns (bool);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

import '../interface/IERC20Minimal.sol';

library TransferHelper {

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20Minimal.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

   
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20Minimal.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IChaChaLP{
     function getMultiplierForLp(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IChaChaNFT{
     function getMultiplierForNFT(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IChaChaNode{
     function getMultiplierForNode(uint256 _from, uint256 _to)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;

interface IChaChaSwitch{
     function setStart()
        external
        returns (uint256);
}

// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity >=0.7.6;
interface IERC20Minimal {
    
    function balanceOf(address account) external view returns (uint256);

  
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

 
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
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