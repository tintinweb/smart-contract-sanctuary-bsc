// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./Ownable.sol";
import "./ERC721A.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";
import "./DateTime.sol";

interface Relation {
    function getForefathers(address owner,uint num) external view returns(address[] memory fathers);
    function childrenOf(address owner) external view returns(address[] memory);
}

contract HappyCats is Ownable, ERC721A, ReentrancyGuard {

    uint256 public maxPerAddressDuringMint = 100; // 每个地址限制mint数量
    bool public preSaleState = true; // 预售是否开启
    Relation public relation; // 推荐关系
    address public CFO;

    // // metadata URI
    string private _baseTokenURI;
    string private _defaultTokenURI;
    
    mapping (address => uint256) public _shareMapping; // 份额

    mapping (uint8 => uint256) public salePriceMapping; // 0 TCD销售价格 1 UDS销售价格
    mapping (uint8 => IERC20) public paymentCurrencyMapping; // 0 TCD支付方式 1 USD支付方式
    mapping (address => uint256) public totalRewardByUSDMapping; // 每个地址USD奖励数额
    mapping (address => uint256) public totalRewardByTCDMapping; // 每个地址TCD奖励数额

    uint256 public presale;    // 预售mint数量

    constructor(IERC20 TCD, IERC20 USD, address relationAddr, address CFOAddr, string memory defaultTokenURI) ERC721A("HappyCats", "HAPPTCATS", 20, type(uint256).max) ReentrancyGuard() {
        salePriceMapping[0] = 20 ether;
        salePriceMapping[1] = 300 ether;
        paymentCurrencyMapping[0] = TCD;
        paymentCurrencyMapping[1] = USD;
        relation = Relation(relationAddr);
        CFO = CFOAddr;
        _defaultTokenURI = defaultTokenURI;
    }

    // 付费mint
    function mint(uint256 quantity, uint8 paymentMethod) external nonReentrant {
        require(paymentMethod == 1, "Wrong payment method");
        require(_numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint);
        require(presale <= 5000, "Insufficient number");
        require(preSaleState, "Pre-sale not started");
        uint256 totalCost = salePriceMapping[paymentMethod] * quantity; // 总花费

        uint256 totalReward  = 0; // 总奖励数量
        address[] memory fathers = relation.getForefathers(msg.sender, 11); // 11级推荐关系
        for (uint256 i = 0; i < fathers.length; i++) {
            if (fathers[i] == address(0) || fathers[i] == address(0xdeaddead)) { // 零地址直接退出
                break;
            }

            if (_shareMapping[fathers[i]] == 0) {
                continue;
            }

            if (i == 0) { // %10奖励
                paymentCurrencyMapping[paymentMethod].transferFrom(msg.sender, fathers[i], totalCost * 10 / 100);
                totalRewardByUSDMapping[fathers[i]] += totalCost * 10 / 100;
                totalReward += totalCost * 10 / 100;
            } else { // %1奖励
                paymentCurrencyMapping[paymentMethod].transferFrom(msg.sender, fathers[i], totalCost / 100);
                totalRewardByUSDMapping[fathers[i]] += totalCost / 100;
                totalReward += totalCost / 100;
            }
        }
        paymentCurrencyMapping[paymentMethod].transferFrom(msg.sender, CFO, totalCost - totalReward); // 支付金额
        _shareMapping[msg.sender] += quantity;
        _safeMint(msg.sender, quantity); // mint
        presale += quantity;
    }

    // 开发团队mint
    function devMint(uint256 quantity) external nonReentrant onlyOwner {
        _safeMint(msg.sender, quantity);
    }

    // mint数量
    function numberMinted(address[] memory addresses) external view returns (uint256[] memory nums) {
        require(addresses.length <= 20, "addresses.lenth over 20");
        nums = new uint256[](addresses.length);
        for (uint256 i = 0; i < addresses.length; i++) {
            nums[i] = _numberMinted(addresses[i]);
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function _defaultURI() internal view virtual override returns (string memory) {
        return _defaultTokenURI;
    }

    function changeMaxMintPerAddress(uint256 newMintAmount) external onlyOwner {
        maxPerAddressDuringMint = newMintAmount;
    }

    function changePreSaleState(bool state) external onlyOwner {
        preSaleState = state;
    }

    function changeSalePrice(uint256 salePriceInTCD, uint256 salePriceInUSD) external onlyOwner {
        salePriceMapping[0] = salePriceInTCD;
        salePriceMapping[1] = salePriceInUSD;
    }

    function changePaymentCurrency(IERC20 TCD, IERC20 USD) external onlyOwner {
        paymentCurrencyMapping[0] = TCD;
        paymentCurrencyMapping[1] = USD;
    }

    function changeCFO(address CFOAddr) external onlyOwner {
        CFO = CFOAddr;
    }

    function changeRelation(address relationAddr) external onlyOwner {
        relation = Relation(relationAddr);
    }

    function setErc20With(address _con, address _addr, uint256 _amount) external onlyOwner {
        IERC20(_con).transfer(_addr, _amount);
    }
}