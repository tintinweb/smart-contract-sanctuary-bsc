//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract WETH9 {
    string public name     = "Example ERC20 Token";
    string public symbol   = "ERC20";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;
    uint                                            public  totalSupply;

    constructor() {
        _mint(msg.sender, 10000e18);
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad, "ERC20: No balance");

        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad, "ERC20: No approve");
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        emit Transfer(src, dst, wad);

        return true;
    }

    function _mint(address dst, uint wad) internal {
        balanceOf[dst] += wad;
        totalSupply += wad;
        emit Transfer(address(0), dst, wad);
    }

    function _burn(address src, uint wad) internal {
        balanceOf[src] -= wad;
        totalSupply -= wad;
        emit Transfer(src, address(0), wad);
    }

    function mint(uint256 wad) external {
        _mint(msg.sender, wad);
    }

    function burn(uint256 wad) external {
        _burn(msg.sender, wad);
    }
}