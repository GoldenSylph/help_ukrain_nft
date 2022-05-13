// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "./TokenInfo.sol";
import "./ERC721Tradable.sol";

contract HelpUkrain is ERC721Tradable {

    TokenInfo private tokenInfo;
    address public author;

    constructor(address _tokenInfo) ERC721Tradable("Help Ukrain", "HU") {
        tokenInfo = TokenInfo(_tokenInfo);
        author = msg.sender;
    }

    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override {
        return super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return tokenInfo.build(_tokenId);
    }

    function mintTo(address _to, uint256 _amount) public {
        require(_msgSender() == author, "onlyAuthor");
        for (uint i = 0; i < _amount; i++) {
            _mintTo(_to);
        }
    }
}
