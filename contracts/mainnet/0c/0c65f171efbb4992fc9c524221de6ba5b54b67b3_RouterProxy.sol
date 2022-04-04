/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IForsage {
    function registrationFor(address userAddress, address referrerAddress) external;
    function BASIC_PRICE() external view returns(uint);
}

interface IForsageExpress {
     function buyNewLevelFor(address userAddress, uint8 level) external payable;
    function levelPrice(uint8 level) external view returns(uint);
}

interface IPancakeRouter {
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    /**
     * @dev This is a virtual function that should be overriden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation() internal virtual view returns (address);

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     * 
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    function _fallback() internal {
        _beforeFallback();
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () payable external {
        _fallback();
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if call data
     * is empty.
     */
    receive () payable external {
        _fallback();
    }

    /**
     * @dev Hook that is called before falling back to the implementation. Can happen as part of a manual `_fallback`
     * call, or as part of the Solidity `fallback` or `receive` functions.
     * 
     * If overriden should call `super._beforeFallback()`.
     */
    function _beforeFallback() internal virtual {
    }
}


contract RouterProxy is Proxy {
    
    address public impl;
    address public contractOwner;

    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner); 
        _; 
    }

    constructor(address _impl) public {
        impl = _impl;
        contractOwner = msg.sender;
    }
    
    function update(address newImpl) public onlyContractOwner {
        impl = newImpl;
    }

    function removeOwnership() public onlyContractOwner {
        contractOwner = address(0);
    }
    
    function _implementation() internal override view returns (address) {
        return impl;
    }
}


interface IForsageRouter {
    function forsageExpressRegistration(address referrerAddress) external payable;
}

contract ForsageRouterBasic {
    address public impl;
    address public contractOwner;

    IERC20 public busd;

    IPancakeRouter public pancakeRouter;
    IForsage public forsage;
    IForsageExpress public forsageExpress;
}

contract ForsageRouter is ForsageRouterBasic {

    //forsage - 0x5acc84a3e955bdd76467d3348077d003f00ffb97
    //pancakeRouter - 0x10ED43C718714eb63d5aA57B78B54704E256024E
    function init(IForsage _forsage, IForsageExpress _forsageExpress, IPancakeRouter _pancakeRouter) public {
        require(msg.sender == contractOwner, "onlyContractOwner");
        busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        forsage = _forsage;
        pancakeRouter = _pancakeRouter;
        forsageExpress = _forsageExpress;

        busd.approve(address(forsage), type(uint256).max);
    }

    fallback() external payable {
        
    }

    function forsageRegistration(address referrerAddress) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2;

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        forsage.registrationFor(msg.sender, referrerAddress);
        
        if(address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }   
    }

    function forsageExpressRegistration(address referrerAddress, uint8 level) public payable {
        uint amountOut = forsage.BASIC_PRICE() * 2;

        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        address to = address(this);
        uint deadline = block.timestamp + 1000;

        pancakeRouter.swapETHForExactTokens{value: msg.value}(amountOut, path, to, deadline);

        forsage.registrationFor(msg.sender, referrerAddress);
        forsageExpress.buyNewLevelFor{value: forsageExpress.levelPrice(level)}(msg.sender, level);
        
        if(address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }   
    }
}