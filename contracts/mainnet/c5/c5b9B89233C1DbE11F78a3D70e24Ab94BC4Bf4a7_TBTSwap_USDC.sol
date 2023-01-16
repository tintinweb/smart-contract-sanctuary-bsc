/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ERC20 {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        require(_allowed[from][msg.sender] >= value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender] - (value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal {
        require(to != address(0));
        _balances[from] = _balances[from] - (value);
        _balances[to] = _balances[to] + (value);
        emit Transfer(from, to, value);
    }
}

contract TBTSwap_USDC {
    uint256 public usdc_rate = 30000000000000000000;
    uint256 public tbt_rate = 30000000000000000000;
    ERC20 public usdc = ERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    ERC20 public tbt = ERC20(0xd7F97f2cBcDC696484dA7C04AD012723392Ce30B);
    address admin = address(0xaDD61d79131960F2e2f9c209bCc45D91C6d2A435);
    mapping(address => bool) public tbt_white_list;
    mapping(address => bool) public usdc_white_list;
    mapping(address => bool) public controller;

    modifier OnlyAdmin() {
        require(msg.sender == admin, "Messaga Sender not admin");
        _;
    }

    modifier IsController() {
        require(
            controller[msg.sender] == true,
            "Messaga Sender not controller"
        );
        _;
    }

    constructor() {
        controller[0x0091778B68A0563B9Cdbab3C4774a7D21A579168] = true;
        controller[admin] = true;
    }

    //設定設定匯率的人
    function set_controller(address _controller) public OnlyAdmin {
        if (!controller[_controller]) {
            controller[_controller] = true;
        } else {
            controller[_controller] = false;
        }
    }

    //設定匯率
    function set_usdc_rate(uint256 _new_usdc_rate) public IsController {
        usdc_rate = _new_usdc_rate;
    }

    //設定匯率
    function set_tbt_rate(uint256 _new_tbt_rate) public IsController {
        tbt_rate = _new_tbt_rate;
    }

    //設定可投tbt白名單
    function set_tbt_white_list(address _user) public IsController {
        if (!tbt_white_list[_user]) {
            tbt_white_list[_user] = true;
        } else {
            tbt_white_list[_user] = false;
        }
    }

    //設定可投usdc白名單
    function set_usdc_white_list(address _user) public IsController {
        if (!usdc_white_list[_user]) {
            usdc_white_list[_user] = true;
        } else {
            usdc_white_list[_user] = false;
        }
    }

    //tbt to usdc
    function change_usdc(uint256 _amount) public {
        require(usdc_white_list[msg.sender] == true, "user not in white list");
        tbt.transferFrom(msg.sender, address(this), _amount);
        uint256 usdc_amount = (_amount * (1e18)) / (tbt_rate);
        usdc.transfer(msg.sender, usdc_amount);
    }

    //usdc to tbt
    function change_tbt(uint256 _amount) public {
        require(tbt_white_list[msg.sender] == true, "user not in white list");
        usdc.transferFrom(msg.sender, address(this), _amount);
        uint256 tbt_amount = (_amount * (usdc_rate)) / (1e18);
        tbt.transfer(msg.sender, tbt_amount);
    }

    //合約中的 usdc 數量
    function balance_usdc() public view returns (uint256) {
        return usdc.balanceOf(address(this));
    }

    //合約中的 tbt 數量
    function balance_tbt() public view returns (uint256) {
        return tbt.balanceOf(address(this));
    }

    //管理者出金
    function admin_take(uint256 token_id, uint256 _amount) public IsController {
        if (token_id == 1) {
            usdc.transfer(admin, _amount);
        } else if (token_id == 2) {
            tbt.transfer(admin, _amount);
        } else {
            revert("error token_id)");
        }
    }
}