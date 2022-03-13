/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

interface IERC721Enumerable {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}


contract SwapPool is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    bool public canSwap = false;
    bool public canClaim = false;
    bool public canBuyBack = false;
    IERC20 public swapToken;
    address public buybackToken;
    uint256 public swapPrice;
    uint256 public buybackPrice;
    uint256 public buybackNum = 0;
    IERC721Enumerable public SwapNFT;
    uint256 public claimTimes = 0;
    mapping(uint256 => uint256) public canClaimBlockNumList;
    mapping(uint256 => uint256) public canClaimAmountList;
    mapping(address => mapping(uint256 => uint256)) public canClaimAmount;
    mapping(address => mapping(uint256 => mapping(uint256 => claimiItem))) public userClaimList;
    mapping(address => uint256[]) public userTokenIdList;
    mapping(address => mapping(uint256=>bool)) public userBuyBackList;

    struct claimiItem {
        uint256 tokenId;
        bool hasClaim;
    }
    
    function enableSwap() external onlyOwner {
        canSwap = true;
    }
    
    function disableSwap() external onlyOwner {
        canSwap = false;
    }
    
    
    function enableClaim() external onlyOwner {
        canClaim = true;
    }
    
    function disableClaim() external onlyOwner {
        canClaim = false;
    }
    
    function enableBuyBack() external onlyOwner {
        canBuyBack = true;
    }
    
    function disableBuyBack() external onlyOwner {
        canBuyBack = false;
    }

    function setSwapInfo(IERC20 _swapToken, uint256 _swapPrice, IERC721Enumerable _SwapNFT) public onlyOwner {
        swapToken = _swapToken;
        swapPrice = _swapPrice;
        SwapNFT = _SwapNFT;
    }
    
    function setBuyBackInfo(address _buybackToken, uint256 _buybackPrice) public onlyOwner {
        buybackToken = _buybackToken;
        buybackPrice = _buybackPrice;
    }

    function claimTimeLines(uint256[] memory timeList, uint256[] memory amountList) public onlyOwner {
        claimTimes = 0;
        for (uint256 i = 0; i < timeList.length; i++) {
            canClaimBlockNumList[i] = timeList[i];
            canClaimAmountList[i] = amountList[i];
            claimTimes = claimTimes.add(1);
        }
    }

    function SwapToken(uint256 _tokenId) public {
        require(canSwap,"k0");
        require(swapPrice>0,"k1");
        userTokenIdList[msg.sender].push(_tokenId);
        SwapNFT.transferFrom(msg.sender, 0x000000000000000000000000000000000000dEaD, _tokenId);
        canClaimAmount[msg.sender][_tokenId] = swapPrice;
        for (uint256 i = 0; i < claimTimes; i++) {
            userClaimList[msg.sender][_tokenId][i] = claimiItem(_tokenId, false);
        }
    }

    function getUserTokenIdList(address _address) public view returns (uint256[] memory) {
        return userTokenIdList[_address];
    }

    function claimToken(uint256 _tokenId, uint256 _time) public {
        require(canClaim,"k0");
        require(canClaimAmount[msg.sender][_tokenId] > 0, "e1");
        require(!userClaimList[msg.sender][_tokenId][_time].hasClaim, "e2");
        require(block.timestamp >= canClaimBlockNumList[_time], "e3");
        require(canClaimAmountList[_time]>0,"e4");
        swapToken.safeTransfer(msg.sender, canClaimAmountList[_time]);
        userClaimList[msg.sender][_tokenId][_time].hasClaim = true;
    }

    function takeErc20Token(IERC20 _token) external onlyOwner {
        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0, "e07");
        _token.safeTransfer(msg.sender, amount);
    }
    
    function takeETH() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "e07");
        payable(msg.sender).transfer(amount);
    }
    
    function buyback(uint256 _tokenId) external {
       require(canClaimAmount[msg.sender][_tokenId]>0,"e0");
       require(canBuyBack,"e1");
       require(!userBuyBackList[msg.sender][_tokenId],"e2");
       if (buybackToken == address(0)) {
           payable(msg.sender).transfer(buybackPrice);
       } else {
           IERC20(buybackToken).safeTransfer(msg.sender,buybackPrice);
       }
       userBuyBackList[msg.sender][_tokenId] = true;
       buybackNum = buybackNum.add(1);
    }
    
    receive() payable external {}

}