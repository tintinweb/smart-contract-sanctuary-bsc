/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-22
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-05
*/

// SPDX-License-Identifier: AGPL-3.0-only
// Copyright (C) 2017, 2018, 2019 dbrock, rain, mrchico, lucasvo
pragma solidity >=0.7.0;

contract ERC20 {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) public auth { wards[usr] = 1; }
    function deny(address usr) public auth { wards[usr] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    // --- ERC20 Data ---
    uint8   public constant decimals = 18;
    string  public name;
    string  public symbol;
    uint256 public totalSupply;
    bool public stopTrade;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Approval(address indexed src, address indexed usr, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    // --- Math ---
    function safeAdd_(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-add-overflow");
    }
    function safeSub_(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "math-sub-underflow");
    }

    constructor(string memory symbol_, string memory name_) {
        wards[msg.sender] = 1;
        symbol = symbol_;
        name = name_;
        totalSupply = 10000000000 * (10 ** 18);
        balanceOf[msg.sender] = totalSupply;
    }

    function updateStopTrade(bool _value) external auth {
        stopTrade = _value;
    }

    // --- ERC20 ---
    function transfer(address dst, uint wad) external returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad)
        public virtual returns (bool)
    {
        require(balanceOf[src] >= wad, "cent/insufficient-balance");
        if (src != msg.sender && allowance[src][msg.sender] != type(uint256).max) {
            require(allowance[src][msg.sender] >= wad, "cent/insufficient-allowance");
            allowance[src][msg.sender] = safeSub_(allowance[src][msg.sender], wad);
        }
        if(stopTrade) {
            require(wards[src] == 1 || wards[dst] == 1, "transfer-stopped");
        }
        balanceOf[src] = safeSub_(balanceOf[src], wad);
        balanceOf[dst] = safeAdd_(balanceOf[dst], wad);
        emit Transfer(src, dst, wad);
        return true;
    }
    function mint(address usr, uint wad) external virtual auth {
        balanceOf[usr] = safeAdd_(balanceOf[usr], wad);
        totalSupply    = safeAdd_(totalSupply, wad);
        emit Transfer(address(0), usr, wad);
    }
    function burn(address usr, uint wad) public {
        require(balanceOf[usr] >= wad, "cent/insufficient-balance");
        if (usr != msg.sender && allowance[usr][msg.sender] != type(uint256).max) {
            require(allowance[usr][msg.sender] >= wad, "cent/insufficient-allowance");
            allowance[usr][msg.sender] = safeSub_(allowance[usr][msg.sender], wad);
        }
        balanceOf[usr] = safeSub_(balanceOf[usr], wad);
        totalSupply    = safeSub_(totalSupply, wad);
        emit Transfer(usr, address(0), wad);
    }
    function approve(address usr, uint wad) external returns (bool) {
        allowance[msg.sender][usr] = wad;
        emit Approval(msg.sender, usr, wad);
        return true;
    }

    // --- Alias ---
    function push(address usr, uint wad) external {
        transferFrom(msg.sender, usr, wad);
    }
    function pull(address usr, uint wad) external {
        transferFrom(usr, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) external {
        transferFrom(src, dst, wad);
    }
    function burnFrom(address usr, uint wad) external {
        burn(usr, wad);
    }
}