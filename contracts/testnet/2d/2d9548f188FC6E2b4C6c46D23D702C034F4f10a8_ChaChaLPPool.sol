// SPDX-License-Identifier: GPL-2.0-or-later

import './interface/IPool.sol';
import './interface/IChaChaDao.sol';
import './interface/IChaCha.sol';
import './interface/IERC20.sol';
import './libraries/TransferHelper.sol';

contract ChaChaLPPool is IPool{

    address private daoAddress;

    address private chachaToken;

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

    function mint(address account, uint256 amount)
        external
        override
        onlyMinter
        returns (bool){
            if(IERC20(chachaToken).balanceOf(address(this)) < amount){
                IChaCha(chachaToken).mint();
            }
        require(IERC20(chachaToken).balanceOf(address(this)) >= amount, "NFT mint may be end");
        TransferHelper.safeTransfer(chachaToken, account, amount);
        return true;
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