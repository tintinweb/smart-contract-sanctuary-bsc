// SPDX-License-Identifier: MIT
// Wrapped LONG Coin (WLONG). This is a token obtained by burning a LONG COIN to an address 
// without a private key: 1111111111111111111114oLvT2. After burning you get a unique coupon 
// in the amount of burned LONG. This coupon is used to top up WLONG at an address 
// in Binance Smart Chain

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./UpgradeableBeacon.sol";
import "./Context.sol";


contract WLONG is UpgradeableBeacon, ERC20 {

    /**
     * @dev 
     * UpgradeableBeacon(address(this)) - означает, что это реализация, вызываемая через Proxy
     * по средствам delegatecall. Наследование от UpgradeableBeacon нужно чтобы отступить от 
     * данных Storage в BeaconProxy, после которых уже располагаются данные самой реализации. 
     */
    constructor() UpgradeableBeacon(address(this)) ERC20("","") {
        // UpgradeableBeacon работает на Storage прокси и конструктор в самом контракте бессмысленен так как Storage
        // реализации не используется и здесь может быть мусор впринципе и он желателен, чтобы без прокси токен сам по себе
        // не обнаруживался! Инициализация, если требуется, должна происходить через delegatecall со стороны прокси путем вызова:
        // функции initialize(), которая объявлется в реализации с модификаторами public и initializer (для одноразовости вызова)
    }
    function initialize() public onlyOwner initializer { // FIXME: Возможно для безопасности достаточно onlyOwner
                                                         // если деплоить контракты достаточно внимательно
        _name = "Wrapped LONG";
        _symbol = "WLONG";
    }

    /** @dev 
     * decimals столькоже сколько и в орегинальном LONG coin, totalSupply изначально 0, так как
     * токены минтятся юзерами
    */
    function decimals() public view virtual override returns (uint8) {
        return 0;
    }


    /////////////////////// А теперь все таинство минтинга обернутой монеты за счет газа минтера ///////////////////////////////

    /** @dev
     * Для проверки купонов на сожженный LONG используем механизм ECDSA-подписи, 
     * где r-часть юзабельна как одноразовый лицензионный ключ.
     * Чтобы не было подделок нужно r=k*G генерировать каждый раз из нового случайного k (nonce)!!!
     * При такой схеме хешь сообщения - это хешь от числа сожженных LONG (со стандартным префиксом),
     * а восстанавливаемый при проверке сигнатуры адрес (публичный ключь) - это _owner-адрес в контракте
    */

    mapping(bytes32 => bool) private _rset;    // r-част подписи созданная из случайного k mod n ( r = k*G  mod n)
                                               // ее достаточно для обеспечения уникальности купона при не повторяемых k
                                               // фактически это и есть купон с приватным ключем k, где r - его публичный ключь

    /** @dev
     * Это единственный метод для минтинга WLONG. Вызывающий адрес долже предоставить валидную
     * сигнатуру (купон), полученную после сжигагия орегинальных LONG в количестве amount
    */
    function mint(uint256 amount, bytes memory signature) external virtual payable returns (bool) {
        //require(signature.length == 64, "WLONG: invalid signature length");

        bytes32 r; bytes32 s; 
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
        }
        require(!_rset[r], "WLONG: key has already been used");

        bytes32 h = _toEthSignedMessageHash(keccak256(abi.encodePacked(amount))); // Хешь сообщения, содержащего число WLONG

        /** @dev
         * Сигнатура генерируется из случайного k, так как r - нужно использовать как номер уникального купона,
         * поэтому при восстановлении точки публичного ключа нужно проверить 2 варианта, которые могут соответсвовать
         * одному и тому-же адресу (координата Y публичного ключа не однозначна, так как у нас есть только адрес (X-координата))
         * Желательно для уникальности сигнатур добиваться при генерации чтобы:
         * s <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
         * ( Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
         *   the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28} )
        */
        address signer1 = ecrecover(h, uint8(27), r, s); address signer2 = ecrecover(h, uint8(28), r, s);
        require(signer1==owner() || signer2==owner(), "WLONG: signature is not valid"); // Проверка публичного ключа подписанта

        // Если сюда дошли, то можно минтить WLONG
        _rset[r]=true;  // Купон одноразовый (запоминаем его)
        _mint(_msgSender(), amount); // Инкрементарная
        
        return true;
    }


    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function _toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

}