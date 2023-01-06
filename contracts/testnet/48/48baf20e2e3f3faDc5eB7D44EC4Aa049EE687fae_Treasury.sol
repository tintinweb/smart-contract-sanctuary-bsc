//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

contract Treasury {
    IERC20 mainToken;
    address owner;
    IERC20 USDT;
    IERC20 USDC;
    IERC20 BUSD;
    IERC20 DAI;


    constructor() {
        owner = msg.sender;
        mainToken = IERC20(0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337);
        USDT = IERC20(0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337);
        USDC = IERC20(0xc3CD1db3Ea3bf1fC711D96831744972284D16cE7);
        BUSD = IERC20(0xF22d9792c7197C3c832B27CCEA92F4e4ee60D337);
        DAI = IERC20(0xc3CD1db3Ea3bf1fC711D96831744972284D16cE7);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not Owner");
        _;
    }

    function swapTokens(
        IERC20 _tokenA,
        IERC20 _tokenB,
        uint256 _amount
    ) external {
        require(_tokenA != _tokenB, "@_tokenA & @_tokenB cannot be Same!");
        require(
            (_tokenA == mainToken) ||
                (_tokenA == USDT ||
                    _tokenA == USDC ||
                    _tokenA == BUSD ||
                    _tokenA == DAI),
            " @_tokenA is Unsupported Token to swap!"
        );
        require(
            (_tokenB == mainToken) ||
                (_tokenB == USDT ||
                    _tokenB == USDC ||
                    _tokenB == BUSD ||
                    _tokenB == DAI),
            "@_tokenB is Unsupported Token to swap!"
        );

        if (_tokenA == mainToken) {
            require(
                _tokenB.balanceOf(address(this)) >= _amount,
                "You cannot Swap Currently with this Token due to less supply!"
            );
            mainToken.burn(msg.sender, _amount);
            _tokenB.transfer(msg.sender, _amount);
        } else {
            _tokenA.transferFrom(msg.sender, address(this), _amount);
            mainToken.mint(msg.sender, _amount);
        }
    }

    function changeMainToken(IERC20 _mainToken) external onlyOwner {
        mainToken = _mainToken;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function withdrawTokens(IERC20 _token, uint256 _amount) external onlyOwner {
        require(
            _token.balanceOf(address(this)) >= _amount,
            "Not have sufficient amount of Collatereal!"
        );

        _token.transfer(msg.sender, _amount);
    }

    function getTotalReserves() public view returns (uint256) {
        return (USDT.balanceOf(address(this)) +
            USDC.balanceOf(address(this)) +
            BUSD.balanceOf(address(this)) +
            DAI.balanceOf(address(this)));
    }

    function getReserves()
        public
        view
        returns (
            uint256 Usdt,
            uint256 Usdc,
            uint256 Busd,
            uint256 Dai
        )
    {
        return (
            USDT.balanceOf(address(this)),
            USDC.balanceOf(address(this)),
            BUSD.balanceOf(address(this)),
            DAI.balanceOf(address(this))
        );
    }
}