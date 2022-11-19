/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-05
 */

// SPDX-License-Identifier: MIT

/*---------------.  .----------------.  .----------------.  .----------------.   .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. || .--------------. | | .--------------. || .--------------. || .--------------. |
| |   ________   | || |  _________   | || |   ______     | || |  ____  ____  | | | |     _____    | || |     ______   | || |     ____     | |
| |  |  __   _|  | || | |_   ___  |  | || |  |_   __ \   | || | |_  _||_  _| | | | |    |_   _|   | || |   .' ___  |  | || |   .'    `.   | |
| |  |_/  / /    | || |   | |_  \_|  | || |    | |__) |  | || |   \ \  / /   | | | |      | |     | || |  / .'   \_|  | || |  /  .--.  \  | |
| |     .'.' _   | || |   |  _|  _   | || |    |  ___/   | || |    > `' <    | | | |      | |     | || |  | |         | || |  | |    | |  | |
| |   _/ /__/ |  | || |  _| |___/ |  | || |   _| |_      | || |  _/ /'`\ \_  | | | |     _| |_    | || |  \ `.___.'\  | || |  \  `--'  /  | |
| |  |________|  | || | |_________|  | || |  |_____|     | || | |____||____| | | | |    |_____|   | || |   `._____.'  | || |   `.____.'   | |
| |              | || |              | || |              | || |              | | | |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' | | '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'   '----------------'  '----------------'  '----------------' */

pragma solidity ^0.8.0;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function totalSupply() external view returns (uint256);
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
}

pragma solidity ^0.8.4;

contract Ownable {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}

contract ZEPCOIN_ICO is Ownable {
    mapping(address => uint256) public Referal_Id;
    mapping(uint256 => address) public _referal_address;
    mapping(address => uint256) public Busd_Earning;
    mapping(uint256 => address) public Usdt_Earning;
    uint256 public Total_member;
    uint256 public current_Price = 5000;
    uint256 public totalRaisedAmount = 0;
    address public Admin_Wallet;
    bool public Refer_status;
    bool public icoStatus;

    constructor(address _Admin_Wallet) {
        Admin_Wallet = _Admin_Wallet;
    }

    function ChangePrice(uint256 NewPrice) external onlyOwner {
        current_Price = NewPrice;
    }

    IERC20 usdt =
        IERC20(
            address(0x3dEb88B4ED555C08aE34F517302A56e960824420) // usdt Token address
        );


    IERC20 ZEPX_TK =
        IERC20(
            address(0x3EEE5653664248E160eb379Cfdae26da1bfa042E) // ZEPX Token address
        );


    IERC20 Busd =
        IERC20(
            address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) // busd Token address
        );

    function BuyToken_usdt(uint256 Usdt_Amount) public {
        require(!icoStatus, "zepcoin ico is stopped");
        require(Usdt_Amount >= 0, "sorry incorect amount");
        usdt.transferFrom(msg.sender, Admin_Wallet, Usdt_Amount);
        ZEPX_TK.transfer(msg.sender, Usdt_Amount * current_Price);
        totalRaisedAmount = totalRaisedAmount + Usdt_Amount;
    }

    function BuyToken_usdt_referal(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(!icoStatus, "zepcoin ico is stopped");
        require(_Amount >= 0, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 busd_Amount = _Amount * 10**18;
        uint256 referal_amount = busd_Amount * 10**17;
        uint256 ico_Amount = busd_Amount - referal_amount;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Referal_Id[msg.sender] = Total_member + 1;
                Total_member = Total_member + 1;
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        } else {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, ico_Amount);
                usdt.transferFrom(msg.sender, referal_address, referal_amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Busd_Earning[referal_address] = referal_amount;
                Referal_Id[msg.sender] = Total_member + 1;
                Total_member = Total_member + 1;
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, ico_Amount);
                usdt.transferFrom(msg.sender, referal_address, referal_amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Busd_Earning[referal_address] = referal_amount;
                Referal_Id[msg.sender] = Total_member + 1;
            }
        }
    }

    function BuyToken_busd(uint256 busd_Amount) public {
        require(!icoStatus, "zepcoin ico is stopped");
        require(busd_Amount >= 0, "sorry insufficient balance");
        Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
        ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
        totalRaisedAmount = totalRaisedAmount + busd_Amount;
    }

    function StopIco() external onlyOwner {
        icoStatus = true;
    }

    function ActivateIco() external onlyOwner {
        icoStatus = false;
    }

    function withdraw_unsoldZEPX(uint256 ZEPX_Ammount) public onlyOwner {
        ZEPX_TK.transfer(msg.sender, ZEPX_Ammount);
    }

    function change_Admin_Wallet(address _new_Admin) public onlyOwner {
        Admin_Wallet = _new_Admin;
    }
}