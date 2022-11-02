// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IDIDAdaptor.sol";

interface IDCard {
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function exists(uint256 tokenId) external view returns (bool);
}

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * PAY MONEY TO BECOME A PREMIUM ID CARD HOLDER.
 */
contract PremiumHolder is IDIDAdaptor {
    bytes32 public constant AccountType_PAID = keccak256("Premium");
    address public idcard;
    address public controller;
    address public money;
    uint256 public immutable price;
    address public operator;
    uint256 public totalBinding;

    mapping(uint256 => address) public premiumHolderOf; // idcard => premium holder
    mapping(address => uint256) public idcardOf; // premium holder => idcard
    mapping(address => bytes32) nonceOf; // payer address => nonce

    event InitAdaptor(
        address idcard,
        address controller,
        address money,
        uint256 price,
        address operator
    );
    event ConnectPayer(uint256 tokenId, address premiumHolder);
    event DisconnectPayer(uint256 tokenId, address premiumHolder);
    event Withdraw(address to, uint256 amount);
    event TransferOperator(address to);

    constructor(
        address idcard_,
        address controller_,
        address money_,
        uint256 price_
    ) {
        idcard = idcard_;
        controller = controller_;
        money = money_;
        price = price_;
        operator = msg.sender;
        emit InitAdaptor(idcard, controller, money, price, operator);
    }

    /// @notice Connect ID card to a premium holder address.
    function connect(
        uint256 tokenId,
        address claimer,
        bytes32 accountType,
        bytes memory sign_info
    ) public override returns (bool) {
        require(msg.sender == controller);
        if (accountType == AccountType_PAID) {
            if (
                idcardOf[claimer] != 0 &&
                IDCard(idcard).exists(idcardOf[claimer])
            ) {
                return false;
            }
            address payer;
            if (sign_info.length == 0) {
                payer = claimer;
            } else {
                (
                    uint256 amount,
                    bytes32 nonce,
                    bytes32 r,
                    bytes32 s,
                    uint8 v
                ) = abi.decode(
                        sign_info,
                        (uint256, bytes32, bytes32, bytes32, uint8)
                    );
                bytes32 hashMessage = keccak256(
                    abi.encodePacked(amount, claimer, nonce)
                );
                payer = ecrecover(hashMessage, v, r, s);
                if (getNonce(payer) != nonce) {
                    return false;
                }
                updateNonce(payer);
            }

            _pay(payer);
            premiumHolderOf[tokenId] = claimer;
            idcardOf[claimer] = tokenId;
            totalBinding += 1;
            emit ConnectPayer(tokenId, claimer);
            return true;
        }
        return false;
    }

    function getNonce(address payer) public view returns (bytes32) {
        if (nonceOf[payer] == bytes32(0)) {
            return keccak256(abi.encodePacked("payer's nonce", payer));
        }
        return nonceOf[payer];
    }

    function updateNonce(address payer) public {
        nonceOf[payer] = keccak256(
            abi.encodePacked("payer's nonce", nonceOf[payer])
        );
    }

    /// @notice Disconnect ID card from a premium holder address.
    function disconnect(uint256 tokenId) external override returns (bool) {
        require(msg.sender == controller);
        address premiumHolder = premiumHolderOf[tokenId];
        idcardOf[premiumHolder] = 0;
        premiumHolderOf[tokenId] = address(0);
        totalBinding -= 1;
        emit DisconnectPayer(tokenId, premiumHolder);
        return true;
    }

    /// @notice Verify if the ID card holder is a premium holder.
    function verifyAccount(uint256 tokenId)
        public
        view
        override
        returns (bool res)
    {
        try this.equalOwner(tokenId, premiumHolderOf[tokenId]) returns (
            bool equal
        ) {
            res = equal;
        } catch {
            res = false;
        }
        return res;
    }

    function equalOwner(uint256 tokenId, address premiumHolder)
        public
        view
        returns (bool)
    {
        return (IDCard(idcard).ownerOf(tokenId) == premiumHolder);
    }

    function getPermitMessage(address payer, address payFor)
        external
        view
        returns (bytes memory)
    {
        return abi.encodePacked(price, payFor, getNonce(payer));
    }

    function encodeSignature(
        uint256 amount,
        bytes32 nonce,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external pure returns (bytes memory) {
        return abi.encode(amount, nonce, r, s, v);
    }

    function _pay(address payer) internal {
        bool succ = IERC20(money).transferFrom(payer, address(this), price);
        require(succ, "payment failed");
    }

    function withdraw(address to, uint256 amount) external {
        require(msg.sender == operator);
        IERC20(money).transferFrom(address(this), to, amount);
        emit Withdraw(to, amount);
    }

    function transferOperator(address to) external {
        require(msg.sender == operator);
        operator = to;
        emit TransferOperator(to);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface for DID adaptor.
 * DAO users can sign up with 3rd party DID protocols, eg Binance BABT, ENS, etc.
 */
interface IDIDAdaptor {
    function connect(
        uint256 tokenId,
        address claimer,
        bytes32 accountType,
        bytes memory sign_info
    ) external virtual returns (bool);

    function verifyAccount(uint256 tokenId)
        external
        view
        virtual
        returns (bool);

    function disconnect(uint256 tokenId) external virtual returns (bool);

    function totalBinding() external returns (uint256);
}