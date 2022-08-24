// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

interface IUSD {
    function owner() external view returns (address);

    function burn(address account, uint256 amount) external;

    function mint(address to, uint256 amount) external;

    function depositAddress() external view returns (address);
}

interface IDepositUSD {
    function withdrawToken(
        address token_,
        address to_,
        uint256 amount_
    ) external;
}

contract UsdMinter {
    address public immutable dusdAddress; // usd token address
    address public immutable depositAddress; // 存款合约地址
    address public immutable usdtAddress; // usdt
    mapping(address => bool) public whiteList;

    constructor(address usd_, address usdt_) {
        dusdAddress = usd_;
        usdtAddress = usdt_;
        depositAddress = IUSD(usd_).depositAddress();
    }

    modifier onlyOwner() {
        require(
            msg.sender == IUSD(dusdAddress).owner(),
            "caller is not the owner"
        );
        _;
    }

    function setWhiteList(address addr, bool status) external onlyOwner {
        whiteList[addr] = status;
    }

    function mintTo(address _account, uint256 usdAmount)
        external
        returns (uint256)
    {
        require(whiteList[msg.sender], "not allow");

        TransferHelper.safeTransferFrom(
            usdtAddress,
            msg.sender,
            depositAddress,
            usdAmount
        );

        IUSD(dusdAddress).mint(_account, usdAmount);
        return usdAmount;
    }

    function burnTo(address _account, uint256 usdAmount)
        external
        returns (uint256 tokenAmount)
    {
        require(whiteList[msg.sender], "not allow");
        require(
            usdAmount <= IERC20(usdtAddress).balanceOf(depositAddress),
            "burn amount overflow error"
        );

        IUSD(dusdAddress).burn(msg.sender, usdAmount);
        IDepositUSD(depositAddress).withdrawToken(
            usdtAddress,
            _account,
            usdAmount
        );
        return tokenAmount;
    }
}