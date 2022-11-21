/**
 *Submitted for verification at BscScan.com on 2022-11-21
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

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

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
    using Strings for uint256;
    mapping(address => uint256) Referal_Id;
    mapping(uint256 => address) public _referal_address;
    mapping(address => uint256) public Zepx_Earning;
    string private Base_url = "www.test.io/?";
    uint256 public Total_member = 1;
    uint256 public Referal_Percentage = 5;
    uint256 public current_Price = 2000;
    uint256 public totalRaisedAmount = 0;
    address public Admin_Wallet;
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
            address(0x3dEb88B4ED555C08aE34F517302A56e960824420) // busd Token address
        );

    function GetUser_address(uint256 _id) public view returns (address) {
        return _referal_address[_id];
    }

    function _baseURl() internal view virtual returns (string memory) {
        return Base_url;
    }

    function GetUser_Id (address _address) public view returns (uint256) {
        return Referal_Id[_address];
    }

    function Change_Url(string memory New_Url) public onlyOwner {
        Base_url = New_Url;
    }

    function Get_referal_url(address _user_address)
        public
        view
        virtual
        returns (string memory)
    {
        uint256 current_id = Referal_Id[_user_address];
        string memory currentBaseURl = _baseURl();
        return
            bytes(currentBaseURl).length > 0
                ? string(
                    abi.encodePacked(currentBaseURl, current_id.toString())
                )
                : "";
    }

    function Create_referal_url(address _user_address) external onlyOwner {
        uint256 old_id = Referal_Id[_user_address];
        if (old_id == 0) {
            uint256 new_id = Total_member + 1;
            Referal_Id[_user_address] = new_id;
            _referal_address[new_id] = _user_address;
            Total_member + 1;
        } else {
            Referal_Id[_user_address] = old_id;
            _referal_address[old_id] = _user_address;
        }
    }

    function BuyToken_Usdt_referal(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(!icoStatus, "zepcoin ico is stopped");
        require(_Amount >= 0, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 busd_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Referal_Id[msg.sender] = Total_member + 1;
                _referal_address[Total_member + 1] = msg.sender;
                Total_member = Total_member + 1;
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        } else {
            if (user_id == 0) {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Zepx_Earning[referal_address] = referal_amount * current_Price;
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Referal_Id[msg.sender] = Total_member + 1;
                _referal_address[Total_member + 1] = msg.sender;
                Total_member = Total_member + 1;
            } else {
                usdt.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                Zepx_Earning[referal_address] = referal_amount * current_Price;
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        }
    }

    function BuyToken_Busd_referal(uint256 _Amount, uint256 _Referal_Id)
        public
    {
        require(!icoStatus, "zepcoin ico is stopped");
        require(_Amount >= 0, "sorry incorect amount");
        uint256 user_id = Referal_Id[msg.sender]; // user id here
        address referal_address = _referal_address[_Referal_Id]; // referal address here
        uint256 busd_Amount = _Amount * 10**18;
        uint256 referal_amount = _Amount * 10**16 * Referal_Percentage;
        if (_Referal_Id == 0) {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Referal_Id[msg.sender] = Total_member + 1;
                _referal_address[Total_member + 1] = msg.sender;
                Total_member = Total_member + 1;
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        } else {
            if (user_id == 0) {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                ZEPX_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                 Zepx_Earning[referal_address] = referal_amount * current_Price;
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
                Referal_Id[msg.sender] = Total_member + 1;
                _referal_address[Total_member + 1] = msg.sender;
                Total_member = Total_member + 1;
            } else {
                Busd.transferFrom(msg.sender, Admin_Wallet, busd_Amount);
                Zepx_Earning[referal_address] = referal_amount * current_Price;
                ZEPX_TK.transfer(
                    referal_address,
                    referal_amount * current_Price
                );
                ZEPX_TK.transfer(msg.sender, busd_Amount * current_Price);
                totalRaisedAmount = totalRaisedAmount + busd_Amount;
            }
        }
    }

    function StopIco() external onlyOwner {
        icoStatus = true;
    }

    function ActivateIco() external onlyOwner {
        icoStatus = false;
    }

    function withdraw_unsoldZEPX(uint256 ZEPX_Ammount) public onlyOwner {
        ZEPX_TK.transfer(msg.sender, ZEPX_Ammount * 10**18);
    }

    function change_Admin_Wallet(address _new_Admin) public onlyOwner {
        Admin_Wallet = _new_Admin;
    }
}