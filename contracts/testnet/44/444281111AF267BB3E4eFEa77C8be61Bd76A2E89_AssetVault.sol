// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../libraries/TransferHelper.sol";

contract AssetVault {

    address public assetAddress;
    address private controller; 

    constructor(address _assetAddress, address _assetControllerAddress) {
        assetAddress = _assetAddress;
        controller = _assetControllerAddress;
    }

    modifier onlyController() {
        require(msg.sender == controller, "Only available to the assetController"); 
        _;
    }

    // add some of the asset, accessible only by controller // only after approval via script
    function vaultAsset(address _depositor, uint256 _amount) external onlyController {
        // IERC20(assetAddress).transferFrom(_depositor, address(this), _amount); 
        TransferHelper.safeTransfer(assetAddress, address(this), _amount);
    }

    // allow the depositor to withdraw an amount of the asset
    function approveDevaulter(uint256 _amount) external onlyController {
        IERC20(assetAddress).approve(address(this), _amount);
    }

    // withdraw some of the asset, accessible only by controller // only after approval via approveDevaulter
    function devaultAsset(address _recipient, uint256 _amount) external onlyController { 
        IERC20(assetAddress).transferFrom(address(this), _recipient, _amount);
    }

    // add counterasset during swaps, accessible only by controller // only after approval via script
    function vaultCounterasset(address _depositor, address _counterassetAddress, uint256 _amount) external onlyController {
        IERC20(_counterassetAddress).transferFrom(_depositor, address(this), _amount);
    }

    // allow the depositor to withdraw an amount of a counterasset
    function approveCounterassetDevaulter(address _counterassetAddress, uint256 _amount) external onlyController {
        IERC20(_counterassetAddress).approve(address(this), _amount);
    }

    // withdraw counterasset, accessible only by controller // only after approval via approveCounterassetDevaulter
    function devaultCounterasset(address _recipient, address _counterassetAddress, uint256 _amount) external onlyController {
        IERC20(_counterassetAddress).transferFrom(address(this), _recipient, _amount);
    }

}

//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0;

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

//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0;

import '../interfaces/IERC20Minimal.sol';

library TransferHelper {
    
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }
}