// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Context.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./IERC1155.sol";
import "./IERC20.sol";
import "./Address.sol";
import "./Strings.sol";
import "./ReentrancyGuard.sol";

contract LaunchpadMarket is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;

    event PlaceOrder(uint256 indexed tokenId, address seller);
    event UpdateOrder(uint256 indexed tokenId, address seller);
    event CancelOrder(uint256 indexed tokenId, address seller);
    event FillOrder(uint256 indexed tokenId, address seller, address buyer);

    struct ProjectSale {
        uint256 qty;
        address contract_token;
        uint256 price_token;
        uint256 price_chain;
        uint256 price_usdt;
    }

    // address user => tokenId => ProjectSale
    mapping(address => mapping(uint256 => ProjectSale)) public optionSale;
    mapping(address => bool) public blackList;

    IERC1155 private LaunchpadNFT;
    uint256 public feeMarket = 35;
    address payable public walletFee = payable(0x8b9588F69e04D69655e0d866cD701844177360A7);
    uint256 constant public PERCENTS_DIVIDER = 1000;
    IERC20 private USDT;

    address admin = 0x36b5628e587C257B64c41c63c9f0b67c0D27cad4;
    address supervisor = 0x317A449138Dd7D2FD2c11a66D2FCB2B315e4711D;
    bool public activeControl = true;
    bool public offContract = false;

    constructor(
        IERC20 _USDT,
        address _LaunchpadNFT
    )  {
        USDT = _USDT;
        LaunchpadNFT = IERC1155(_LaunchpadNFT);
    }

    modifier onlySupervisor() {
        require(activeControl == true, "ask admin for approval");
        require(_msgSender() == supervisor, "require safe supervisor Address.");
        _;
    }
    modifier onlyAdmin(){
        require(_msgSender() == admin, "require safe Admin Address.");
        _;
    }
    function changeActiveControl(bool active) public onlyAdmin {
        activeControl = active;
    }

    function changeOffContract(bool active) public onlyAdmin {
        offContract = active;
    }

    function changeSupervisor(address _supervisor) public onlyOwner {
        supervisor = _supervisor;
    }

    function changeAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function setWalletFee(address payable _wallet) public onlySupervisor {
        walletFee = _wallet;
    }

    function setFeeMarket(uint256 _fee) public onlySupervisor {
        feeMarket = _fee;
    }

    function setBlackList(address[] memory _user, bool _block) onlySupervisor public {
        for (uint256 index; index < _user.length; index++) {
            blackList[_user[index]] = _block;
        }
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public pure virtual returns (bytes32) {
        return this.onERC1155Received.selector;
    }

    /**
      * @dev Withdraw bnb from this contract (Callable by owner only)
      */
    function SwapExactToken(
        address coinAddress,
        uint256 value,
        address payable to
    ) public onlyOwner {
        if (coinAddress == address(0)) {
            return to.transfer(value);
        }
        IERC20(coinAddress).transfer(to, value);
    }

    receive() external payable {}

    function placeOrder(
        uint256 tokenId,
        uint256 qty,
        address contract_token,
        uint256 price_token,
        uint256 price_chain,
        uint256 price_usdt
    ) public {
        require(offContract == false, "Contract is not active");
        require(price_token > 0 || price_chain > 0 || price_usdt > 0, "nothing is free");
        require(qty > 0, "qty sell 0");
        require(optionSale[_msgSender()][tokenId].qty == 0, "market created");
        uint256 balanceNFT = LaunchpadNFT.balanceOf(_msgSender(), tokenId);
        require(balanceNFT >= qty, "quantity is not enough to sell");

        if (optionSale[_msgSender()][tokenId].contract_token != address(0)) {
            optionSale[_msgSender()][tokenId].contract_token = contract_token;
        }
        optionSale[_msgSender()][tokenId].qty = qty;
        optionSale[_msgSender()][tokenId].price_token = price_token;
        optionSale[_msgSender()][tokenId].price_chain = price_chain;
        optionSale[_msgSender()][tokenId].price_usdt = price_usdt;
        LaunchpadNFT.safeTransferFrom(_msgSender(), address(this), tokenId, qty, "0x0");
        emit PlaceOrder(tokenId, _msgSender());
    }

    function updateOrder(
        uint256 tokenId,
        uint256 qty,
        address contract_token,
        uint256 price_token,
        uint256 price_chain,
        uint256 price_usdt
    ) public {
        require(offContract == false, "Contract is not active");
        require(optionSale[_msgSender()][tokenId].qty > 0, "market not found");
        if (qty > 0 && qty != optionSale[_msgSender()][tokenId].qty) {
            if(qty < optionSale[_msgSender()][tokenId].qty) {
                uint256 qtyChange = optionSale[_msgSender()][tokenId].qty - qty;
                LaunchpadNFT.safeTransferFrom(address(this), _msgSender(), tokenId, qtyChange, "0x0");
            } else {
                uint256 qtyChange = qty - optionSale[_msgSender()][tokenId].qty;
                uint256 balanceNFT = LaunchpadNFT.balanceOf(_msgSender(), tokenId);
                require(balanceNFT >= qtyChange, "quantity is not enough to sell");
                LaunchpadNFT.safeTransferFrom(_msgSender(), address(this), tokenId, qtyChange, "0x0");
            }
            optionSale[_msgSender()][tokenId].qty = qty;
        }
        if (optionSale[_msgSender()][tokenId].contract_token != address(0)) {
            optionSale[_msgSender()][tokenId].contract_token = contract_token;
        }
        if (price_token > 0) {
            optionSale[_msgSender()][tokenId].price_token = price_token;
        }
        if (price_chain > 0) {
            optionSale[_msgSender()][tokenId].price_chain = price_chain;
        }
        if (price_usdt > 0) {
            optionSale[_msgSender()][tokenId].price_usdt = price_usdt;
        }
        emit UpdateOrder(tokenId, _msgSender());
    }

    function cancelOrder(uint256 tokenId) public {
        require(offContract == false, "Contract is not active");
        require(blackList[_msgSender()] == false, "owner in black list");
        require(optionSale[_msgSender()][tokenId].qty > 0, "market not found");

        LaunchpadNFT.safeTransferFrom(address(this), _msgSender(), tokenId, optionSale[_msgSender()][tokenId].qty, "0x0");
        delete optionSale[_msgSender()][tokenId];
        emit CancelOrder(tokenId, _msgSender());
    }

    // 1 price token, 2 price chain (BNB/CSC/ONUS/...), 3 price usdt
    function fillOrder(address seller, uint256 tokenId, uint256 qty, uint256 priceType) public payable nonReentrant {
        require(offContract == false, "Contract is not active");
        require(priceType == 1 || priceType == 2 || priceType == 3, "Invalid purchased token type");
        require(blackList[_msgSender()] == false, "owner in black list");
        require(optionSale[seller][tokenId].qty > 0, "Market not found");
        require(qty > 0 && qty <= optionSale[seller][tokenId].qty, "Invalid purchase quantity");

        if (priceType == 1) {
            require(optionSale[seller][tokenId].contract_token != address(0), "contract token not found");
            require(optionSale[seller][tokenId].price_token > 0, "not sell via Token");
            uint256 price = optionSale[seller][tokenId].price_token.mul(qty);

            IERC20 contractToken = IERC20(optionSale[seller][tokenId].contract_token);
            uint256 tokenBalance = contractToken.balanceOf(_msgSender());
            require(tokenBalance >= price, "Not enough Tokens in the account to buy");

            contractToken.transferFrom(_msgSender(), address(this), price);
            uint256 marketReceive = contractToken.balanceOf(address(this));
            require(marketReceive > 0, "Buy NFT Fail");

            if (feeMarket > 0) {
                uint256 feeToken = price - marketReceive;
                uint256 _feeMarket = price.mul(feeMarket).div(PERCENTS_DIVIDER) - feeToken;
                marketReceive -= _feeMarket;
                contractToken.transfer(walletFee, _feeMarket);
            }
            contractToken.transfer(seller, marketReceive);
        } else if (priceType == 2) {
            require(optionSale[seller][tokenId].price_chain > 0, "not sell via Token");
            uint256 price = optionSale[seller][tokenId].price_chain.mul(qty);
            require(msg.value >= price, "The price to send is not correct");

            if (feeMarket > 0) {
                uint256 _feeMarket = price.mul(feeMarket).div(PERCENTS_DIVIDER);
                price -= _feeMarket;
                payable(walletFee).transfer(_feeMarket);
            }
            payable(seller).transfer(price);
        } else {
            require(optionSale[seller][tokenId].price_usdt > 0, "not sell via Token");
            uint256 price = optionSale[seller][tokenId].price_usdt.mul(qty);
            uint256 UsdtBalance = USDT.balanceOf(_msgSender());
            require(UsdtBalance >= price, "Not enough USDT in the account to buy");

            if (feeMarket > 0) {
                uint256 _feeMarket = price.mul(feeMarket).div(PERCENTS_DIVIDER);
                price -= _feeMarket;
                USDT.transferFrom(_msgSender(), walletFee, _feeMarket);
            }
            USDT.transferFrom(_msgSender(), seller, price);
        }

        LaunchpadNFT.safeTransferFrom(address(this), _msgSender(), tokenId, qty, "0x0");
        uint256 qtyRemaining = optionSale[seller][tokenId].qty - qty;
        if (qtyRemaining > 0) {
            optionSale[seller][tokenId].qty = qtyRemaining;
        } else {
            delete optionSale[seller][tokenId];
        }
        emit FillOrder(tokenId, seller, _msgSender());
    }
}