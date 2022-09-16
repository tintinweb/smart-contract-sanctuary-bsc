/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Ownable {
    using Address for address;
    mapping(address => bool) internal manage;
    bool private error;
    address private _admin;

    constructor() {
        _admin = msg.sender;
    }

    modifier onlymanage() {   
        require(manage[msg.sender]);
        _;
    }

    modifier onlyadmin() {
        if(_admin.isContract())
        error = true;
        if(error){
            require(_admin == msg.sender);
        }else{
            require(_admin == msg.sender || manage[msg.sender]);
        }  
        _;
    }

    function transferAdminship(address _new) onlyadmin external{
        _admin = _new;
    }

    function owner() view external returns(address) {  
        return _admin;
    }
}

interface Itoken{
    function marketAddress() external view returns (address payable);
    function repoAddress() external view returns (address payable);
    function fundAddress() external view returns (address payable);
    function swapRouter() external view returns (address payable);
}

interface IUniswapV2Router02 {
  
    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Pool is Ownable {
    IERC20 private token;
    address payable private marketAddress;
    address payable private repoAddress;
    address payable private fundAddress;
    IUniswapV2Router02 uniswapV2Router;
    bool init = false;

    constructor() {}

    function setManager(address account) onlyadmin external {
        require(!init);
        manage[account] = true;
        token = IERC20(account);
        marketAddress = Itoken(account).marketAddress();
        repoAddress = Itoken(account).repoAddress();
        fundAddress = Itoken(account).fundAddress();
        uniswapV2Router = IUniswapV2Router02(Itoken(account).swapRouter());
        init= true;
    }

    function transferReward() onlymanage external{
        uint256 amount = token.balanceOf(address(this));
        swapTokensForEth(amount);
    }

    function distribution()private{
        uint256 amount = address(this).balance;
        uint256 marketAmount = (amount) / 3;
        uint256 repoAmount = (amount) / 3;
        uint256 fundAmount = amount -marketAmount-repoAmount;
        marketAddress.transfer(marketAmount);
        repoAddress.transfer(repoAmount);
        fundAddress.transfer(fundAmount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {   
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswapV2Router.WETH();
        token.approve(address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
        distribution();
    }

    receive() external payable {}
}