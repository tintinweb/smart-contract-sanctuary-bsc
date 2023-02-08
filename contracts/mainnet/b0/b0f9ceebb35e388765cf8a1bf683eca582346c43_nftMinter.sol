/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

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
    function balanceOf(address owner) external view returns (uint256 balance);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

interface IgoManager {
    function getAllStakingNum(address _user) external view returns (uint256 num);
}

contract nftMinter is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    configItem public config;

    struct configItem {
        uint256 _startBlock;
        uint256 _endBlock;
        uint256 _fee;
        uint256 _maxAmount;
        uint256 _totalAmount;
        uint256 _mintAmount;
        IERC721Enumerable _nftToken;
        IERC721Enumerable _cosoNFT;
        IgoManager _IgoManager;
        address _nftTokenFromAddress;
    }

    mapping(address => uint256) public userAmountList;

    event mintEvent(address _user, uint256 _timestamp, uint256 _tokenID);

    function setConfig(
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _fee,
        uint256 _maxAmount,
        uint256 _totalAmount,
        IERC721Enumerable _nftToken,
        IERC721Enumerable _cosoNFT,
        IgoManager _IgoManager,
        address _nftTokenFromAddress
    ) public onlyOwner {
        setConfig1(_startBlock, _endBlock);
        setConfig2(_fee);
        setConfig3(_maxAmount,_totalAmount);
        setConfig4(_nftToken, _cosoNFT);
        setConfig5(_IgoManager);
        setConfig6(_nftTokenFromAddress);
    }

    function setConfig1(uint256 _startBlock, uint256 _endBlock) public onlyOwner {
        config._startBlock = _startBlock;
        config._endBlock = _endBlock;
    }

    function setConfig2(uint256 _fee) public onlyOwner {
        config._fee = _fee;
    }

    function setConfig3(uint256 _maxAmount,uint256 _totalAmount) public onlyOwner {
        config._maxAmount = _maxAmount;
        config._totalAmount = _totalAmount; 
    }

    function setConfig4(IERC721Enumerable _nftToken, IERC721Enumerable _cosoNFT) public onlyOwner {
        config._nftToken = _nftToken;
        config._cosoNFT = _cosoNFT;
    }

    function setConfig5(IgoManager _IgoManager) public onlyOwner {
        config._IgoManager = _IgoManager;
    }

    function setConfig6(address _nftTokenFromAddress) public onlyOwner {
        config._nftTokenFromAddress = _nftTokenFromAddress;
    }

    function mint(uint256 _amount) external payable nonReentrant {
        require(block.timestamp >= config._startBlock && block.timestamp <= config._endBlock, "e001");
        uint256 allQuote = getQuote(msg.sender);
        require(userAmountList[msg.sender].add(_amount) <= config._maxAmount, "e002");
        require(userAmountList[msg.sender].add(_amount) <= allQuote, "e003");
        userAmountList[msg.sender] = userAmountList[msg.sender].add(_amount);
        uint256 allFee = config._fee.mul(_amount);
        require(msg.value == allFee, "e004");
        for (uint256 i = 0; i < _amount; i++) {
            uint256 tokenID = config._nftToken.tokenOfOwnerByIndex(config._nftTokenFromAddress, 0);
            config._nftToken.transferFrom(config._nftTokenFromAddress, msg.sender, tokenID);
            emit mintEvent(msg.sender, block.timestamp, tokenID);
        }
        config._mintAmount =  config._mintAmount.add(_amount);
        require(config._mintAmount<=config._totalAmount,"e005");
    }

    function getQuote(address _user) public view returns (uint256) {
        uint256 balanceOfCOSO = config._cosoNFT.balanceOf(_user);
        uint256 stakingAmount = config._IgoManager.getAllStakingNum(_user);
        uint256 allQuote = balanceOfCOSO.add(stakingAmount);
        return allQuote.add(1);
    }

    function takeFee() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function getAllInfo(address _user) external view returns(configItem memory _config, uint256 _quote, uint256 _userAmount) {
        _config = config;
        _quote = getQuote(_user);
        _userAmount = userAmountList[_user];
    }

    receive() payable external {}
}