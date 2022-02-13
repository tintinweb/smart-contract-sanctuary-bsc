/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

interface IERC20 {
    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "e0");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "e1");
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "e3");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ow1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ow2");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "e4");
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}

interface fatory {
     function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

// interface router {
//     function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
//     function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
//     function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
//     function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
//     function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
// }


contract RouterHelper is Ownable {
    using SafeMath for uint256;
    //heco
    // router public Router=router(0xED7d5F38C79115ca12fe6C0041abb22F0A06C300);
    // fatory public Fatory=fatory(0xb0b670fc1F7724119963018DB0BfA86aDb22d941);
    // router public Router=router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    // fatory public Fatory=fatory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    struct pathItem {
       address[] path3; 
    }
    
    // function setRouter (router _Router) public onlyOwner {
    //     Router = _Router;
    // }
    
    //   function setFatory (fatory _Fatory) public onlyOwner {
    //     Fatory = _Fatory;
    // }
    
    struct pairItem {
        address pair;
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        // tokenInfoItem token0Info;
        // tokenInfoItem token1Info;
    }
    
    struct tokenInfoItem {
        IERC20 token;
        string name;
        string symbol;
        uint256 decimals;
        uint256 balance;
    }
    
    
    function getPathNew(fatory Fatory,address[] memory pathList) public view returns (pairItem[] memory pairItemList) {
        uint256 num = pathList.length.div(2);
        uint256 t;
        for (uint256 i=0;i<num;i++) {
            address tokenA = pathList[i];
            address tokenB = pathList[i+1];
            address pair2 = Fatory.getPair(tokenA,tokenB);
            if (pair2 != address(0)) {
                t = t.add(1);
            }
        }
        pairItemList = new pairItem[](t);
        t = 0;
        for (uint256 i=0;i<num;i++) {
            address tokenA = pathList[i];
            address tokenB = pathList[i+1];
            address pair2 = Fatory.getPair(tokenA,tokenB);
            if (pair2 != address(0)) {
               (uint256 reserve0, uint256 reserve1,) =  pair(pair2).getReserves();
                pairItemList[t] = pairItem(pair2,pair(pair2).token0(),pair(pair2).token1(),reserve0,reserve1);
                t = t.add(1);
            }
        }
    }
    
    function getPath(fatory Fatory,address[] memory path) public view returns (address[] memory pairaddressList) {
        pairaddressList = new address[](path.length-1);
        for (uint256 i=0;i<path.length-1;i++) {
            address pair2 = Fatory.getPair(path[i],path[i+1]);
            pairaddressList[i] = pair2;
        }
    }
    
     function getPaths(fatory Fatory,pathItem[] memory pathList) public view returns (pathItem[] memory pathListNew,uint256 t) {
        for (uint256 i=0;i<pathList.length;i++) {
            pathItem memory k = pathList[i];
            address[] memory pairaddressList0 = getPath(Fatory,k.path3);
            bool is_ok = true;
            for (uint256 j=0;j<pairaddressList0.length;j++) {
                if (pairaddressList0[j] == address(0)) {
                   is_ok = false;
                }
            }
            if (is_ok) {
                t = t.add(1);
            }
        }
        pathListNew = new pathItem[](t);
        uint256 t2=0;
        for (uint256 i=0;i<pathList.length;i++) {
            pathItem memory k = pathList[i];
            address[] memory pairaddressList0 = getPath(Fatory,k.path3);
            bool is_ok = true;
            for (uint256 j=0;j<pairaddressList0.length;j++) {
                if (pairaddressList0[j] == address(0)) {
                   is_ok = false;
                }
            }
            if (is_ok) {
                pathListNew[t2] = pathList[i];
                t2 = t2.add(1);
            }
        }
    }
    
    struct decimalsListItem {
        uint256 fromDecimals;
        uint256 toDecimals;
    }
    
    struct pairReservesItem {
        address pairAdress;
        address fromAddress;
        address toAddress;
        uint256 fromAmount;
        uint256 toAmount;
        uint256 fromDecimals;
        uint256 toDecimals;
        string fromSymbol;
        string toSymbol;
    }
    
    function getTokensReserves(fatory Fatory,address[] memory path) public view returns (pairReservesItem[] memory pairReservesList) {
        pairReservesList = new pairReservesItem[](path.length-1);
        for (uint256 i=0;i<path.length-1;i++) {
            address from = path[i];
            address to = path[i+1];
            address pair2 = Fatory.getPair(from,to);
            address token0 = pair(pair2).token0();
            (uint256 reserve0, uint256 reserve1,) =  pair(pair2).getReserves();
            uint256 fromAmount;
            uint256 toAmount;
            if (token0 == from) {
                 fromAmount = reserve0;
                 toAmount = reserve1;
            } else {
                fromAmount = reserve1;
                toAmount = reserve0;
            }
            pairReservesList[i] = pairReservesItem(pair2,from,to,fromAmount,toAmount,IERC20(from).decimals(),IERC20(to).decimals(),IERC20(from).symbol(),IERC20(to).symbol());
        } 
    }
    
    struct AmountItem {
        pairReservesItem[] pairReserves;
    }
    
    
    struct massFactoryItem {
     fatory Fatory;
     decimalsListItem decimalsList;
     pathItem[] pathListNew;
     uint256 t;
     AmountItem[] amountList;  
    }
    
    function massGetTokensReserves (fatory Fatory,pathItem[] memory pathList) public view returns (decimalsListItem memory decimalsList,pathItem[] memory pathListNew,uint256 t,AmountItem[] memory amountList) {
        decimalsList = decimalsListItem(IERC20(pathList[0].path3[0]).decimals(),IERC20(pathList[0].path3[pathList[0].path3.length-1]).decimals());
        (pathListNew,t) = getPaths(Fatory,pathList);
        amountList = new AmountItem[](t);
        for (uint256 i=0;i<t;i++) {
            pathItem memory x = pathListNew[i];
            amountList[i] = AmountItem(getTokensReserves(Fatory,x.path3));
        }
    }
    
    
    function multiGetTokensReserves(fatory[] memory FatorList,pathItem[] memory pathList) public view returns (massFactoryItem[] memory massFactoryList) {
        uint256 num = FatorList.length;
        massFactoryList = new massFactoryItem[](num);
        fatory Fatoryitem;
        for (uint256 i=0;i<num;i++) {
            Fatoryitem = FatorList[i];
            (decimalsListItem memory decimalsList,pathItem[] memory pathListNew,uint256 t,AmountItem[] memory amountList) = massGetTokensReserves(Fatoryitem,pathList);
            massFactoryList[i] = massFactoryItem(Fatoryitem,decimalsList,pathListNew,t,amountList);
        }
    }
    
    function massGetTokenBalance(address _address,IERC20[] memory _tokenList) external view returns (tokenInfoItem[] memory tokenInfoList,uint256 balance) {
        balance = _address.balance;
        uint256 num = _tokenList.length;
        tokenInfoList = new tokenInfoItem[](num);
        IERC20 tokenItem;
        for (uint256 i=0;i<num;i++) {
            tokenItem = _tokenList[i];
            tokenInfoList[i] = tokenInfoItem(tokenItem,tokenItem.name(),tokenItem.symbol(),tokenItem.decimals(),tokenItem.balanceOf(_address));
        }
    }

}