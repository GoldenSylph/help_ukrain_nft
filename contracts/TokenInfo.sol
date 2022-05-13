// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Base64.sol";

contract TokenInfo is Ownable {

    uint256 public constant MAX_LINES_AMOUNT = 10;

    mapping(uint256 => mapping(uint256 => string)) lines;
    uint256 public tokensInfoLength;
    uint256 public optionsInfoLength;

    constructor(
      uint256[][] memory lineIndiciesForTokens,
      string[][] memory newLinesForTokens
    ) {
      _addLines(lineIndiciesForTokens, newLinesForTokens);
    }

    function _addLines(
        uint256[][] memory lineIndicies,
        string[][] memory newLines
    ) internal {
        for (uint256 i = 0; i < lineIndicies.length; i++) {
            for (uint256 j = 0; j < lineIndicies[i].length; j++) {
                lines[lineIndicies[i][j]][i] = newLines[i][j];
            }
        }
        tokensInfoLength += newLines.length;
    }

    function addLines(
        uint256[][] memory lineIndicies,
        string[][] memory newLines
    )
        external
        onlyOwner
    {
        _addLines(lineIndicies, newLines);
    }

    function _build(
        uint256 id,
        uint256 offset,
        bool isDecrementInUse,
        string memory frontColor,
        string memory backColor
    )
        internal
        view
        returns (string memory)
    {
        if (isDecrementInUse) {
          id -= 1;
        }
        string memory _shortDescriptionString = lines[9 + offset][id];
        bytes memory _shortDescription = abi.encodePacked(_shortDescriptionString);
        bytes memory _tokenId = abi.encodePacked(toString(id));
        string[8] memory tags = [
            lines[2 + offset][id],
            lines[3 + offset][id],
            lines[4 + offset][id],
            lines[5 + offset][id],
            lines[6 + offset][id],
            lines[7 + offset][id],
            lines[8 + offset][id],
            _shortDescriptionString
        ];

        bytes memory attrs = abi.encodePacked(
            makeAttr("Birthday", lines[1 + offset][id], "date")
        );

        {
            bytes memory _name = abi.encodePacked(lines[offset][id]);
            bytes memory svg = makeSvg(_name, _tokenId, tags, frontColor, backColor);
            return makeJson(_name, _shortDescription, svg, attrs);
        }
    }

    function build(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return _build(tokenId, 0, true, "#0066CC", "#FFCC00");
    }

    function makeJson(
        bytes memory _name,
        bytes memory _shortDescription,
        bytes memory _svg,
        bytes memory _attrs
    ) internal pure returns (string memory) {
        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                _name, '", "description": "`', _shortDescription, '` This is special non-profit token, all of the sales profits are transfered to the Russian Anti-War Commitee, which then are utilized to help the ukrainian refugees.", "image_data": "data:image/svg+xml;base64,',
                Base64.encode(_svg),
                '", "attributes": [',
                _attrs,
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function textTag(
        string memory _txt,
        string memory _yPos
    )
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked('<text x="8" y="', _yPos, '">', _txt, "</text>");
    }

    function makeAttr(string memory _k, string memory _v, string memory _d)
        internal
        pure
        returns (bytes memory)
    {
        if (keccak256(abi.encodePacked(_d)) == keccak256(abi.encodePacked('none'))) {
            return
                abi.encodePacked('{"trait_type": "', _k, '", "value": "', _v, '"}');
        } else if (keccak256(abi.encodePacked(_d)) == keccak256(abi.encodePacked('ranking'))) {
            return
                abi.encodePacked('{"trait_type": "', _k, '", "value": ', _v, '}');
        } else {
            return
                abi.encodePacked('{"trait_type": "', _k, '", "value": "', _v, '", "display_type": "', _d, '"}');
        }
    }

    function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    function makeSvg(
        bytes memory _name,
        bytes memory _tokenId,
        string[8] memory _loot,
        string memory backColor,
        string memory frontColor
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes
            memory head = abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><defs><clipPath id="clp"><rect width="100%" height="100%"/></clipPath><pattern xmlns="http://www.w3.org/2000/svg" patternUnits="userSpaceOnUse" width="25" height="13" patternTransform="scale(2) rotate(0)" id="star"><path d="M25.044 22.25c0 6.904-5.596 12.5-12.5 12.5s-12.5-5.596-12.5-12.5 5.596-12.5 12.5-12.5c5.786 0 10.655 3.932 12.079 9.27.274 1.03.421 2.113.421 3.23m0-9a2.5 2.5 0 00-2.363 1.688 12.5 12.5 0 011.672 3.212v.002a2.5 2.5 0 10.69-4.902zm-.037-5a7.5 7.5 0 00-6.125 3.227 12.5 12.5 0 016.121 11.773h.04a7.5 7.5 0 10-.036-15zm.023-5a12.5 12.5 0 00-10.998 6.588c.097.012.193.025.29.039h.005c.097.014.194.029.29.045h.003c.194.033.388.07.58.113h.004a12.5 12.5 0 011.123.3l.02.007.006.002a12.496 12.496 0 011.077.403l.032.01.033.016c.166.07.33.145.492.223l.016.008.004.002c.176.086.35.177.523.271l.006.002c.085.047.17.094.254.143l.004.002c.085.049.169.099.252.15l.004.002c.083.051.166.103.248.156l.004.002c.082.052.163.106.244.16l.004.002.24.168.004.002c.899.618 1.672 1.418 2.385 2.219l.004.004c.125.151.246.306.363.463l.004.004c.058.078.116.157.172.236l.004.004c.056.08.112.16.166.24l.002.004c.577.817.987 1.72 1.359 2.633l.002.004c.034.091.066.183.098.275l.002.004c.032.092.062.185.092.278l.002.003c.03.094.058.188.086.282l.002.004c.027.093.053.186.078.28l.002.005c.025.095.05.19.072.285l.002.004c.023.095.046.19.067.285.136.57.19 1.141.25 1.713l.003.05.002.04c.013.178.022.356.028.535v.023c.003.098.004.195.004.293v.014a12.5 12.5 0 01-.127 1.777c-.184 1.281-.582 2.34-1.002 3.412a12.505 12.505 0 01-.36.723c.494.059.99.088 1.488.088 6.904 0 12.5-5.596 12.5-12.5s-5.596-12.5-12.5-12.5zm-24.986 10a2.5 2.5 0 10.691 4.902 12.5 12.5 0 011.672-3.214A2.5 2.5 0 00.044 13.25zm-.037-5a7.5 7.5 0 10.078 15 12.5 12.5 0 016.121-11.773A7.5 7.5 0 00.007 8.25zm-.065-5c-6.898.008-12.486 5.602-12.486 12.5 0 6.904 5.596 12.5 12.5 12.5.525 0 1.05-.034 1.57-.1a12.5 12.5 0 019.448-18.3A12.5 12.5 0 00-.044 3.25zm12.602 3.5a2.5 2.5 0 00-2.39 1.773c.3.425.575.868.82 1.327a12.5 12.5 0 013.058-.012 12.5 12.5 0 01.875-1.399 2.5 2.5 0 00-2.363-1.689zm-1.57 3.1a12.5 12.5 0 013.058-.012M12.507 1.75a7.5 7.5 0 00-6.15 3.266 12.5 12.5 0 014.617 4.834 12.5 12.5 0 013.058-.012 12.5 12.5 0 014.676-4.861 7.5 7.5 0 00-6.201-3.227zm5.226 9.129a12.47 12.47 0 010 0zM10.974 9.85a12.5 12.5 0 013.058-.012m3.702 1.041a12.493 12.493 0 01-.001 0zM12.53-3.25a12.5 12.5 0 00-11.004 6.6 12.5 12.5 0 019.448 6.5 12.5 12.5 0 013.058-.012 12.5 12.5 0 019.526-6.498 12.5 12.5 0 00-11.014-6.59zm5.203 14.129a12.47 12.47 0 010 0zM25.043.25a2.5 2.5 0 00-2.362 1.688c.323.447.616.915.877 1.4a12.5 12.5 0 011.472-.088h.014a12.5 12.5 0 012.389.23 2.5 2.5 0 00-2.39-3.23zm-.036-5a7.5 7.5 0 00-6.125 3.227 12.5 12.5 0 014.676 4.86 12.5 12.5 0 011.472-.087h.014c2.5 0 4.944.75 7.014 2.152A7.5 7.5 0 0025.007-4.75zm-1.449 8.088a12.5 12.5 0 011.472-.088h.014m-.014-13a12.5 12.5 0 00-10.998 6.59 12.5 12.5 0 019.526 6.498 12.5 12.5 0 011.472-.088h.014a12.5 12.5 0 0110.678 6 12.5 12.5 0 001.822-6.5c0-6.904-5.596-12.5-12.5-12.5zM14.69 8.75a12.529 12.529 0 000 0zm3.043 2.129a12.47 12.47 0 010 0zM.043.25a2.5 2.5 0 00-2.394 3.217A12.5 12.5 0 01-.058 3.25h.014c.525 0 1.05.034 1.57.1a12.5 12.5 0 01.881-1.41A2.5 2.5 0 00.044.25zm-.036-5A7.5 7.5 0 00-6.987 5.355 12.5 12.5 0 01-.057 3.25h.013c.525 0 1.05.034 1.57.1a12.5 12.5 0 014.682-4.873A7.5 7.5 0 00.007-4.75zm.023-5c-6.898.008-12.486 5.602-12.486 12.5a12.5 12.5 0 001.78 6.428A12.5 12.5 0 01-.059 3.25h.014c.525 0 1.05.034 1.57.1a12.5 12.5 0 019.532-6.51A12.5 12.5 0 00.044-9.75zM9.722 7.951a12.497 12.497 0 010 0z" stroke-width="1" stroke="' , frontColor, '" fill="', backColor, '"/></pattern></defs><style>text{fill:#fff;font-family:Courier New;font-size:13px}.tag{font-size:24px}ellipse{clip-path:url(#clp)}</style><rect width="100%" height="100%" fill="', backColor, '"/><ellipse cx="200" cy="400" rx="350" ry="150" fill="url(#star)"/>');

        bytes memory loots = abi.encodePacked(
            textTag(_loot[0], "50"),
            textTag(_loot[1], "73"),
            textTag(_loot[2], "96"),
            textTag(_loot[3], "119"),
            textTag(_loot[4], "142"),
            textTag(_loot[5], "165"),
            textTag(_loot[6], "188"),
            textTag(_loot[7], "211")
        );

        return
            abi.encodePacked(
                head,
                abi.encodePacked(
                    '<text x="8" y="30" class="tag">',
                    _name,
                    "</text>",
                    '<text x="8" y="244">Token ID: ',
                    _tokenId,
                    "</text>"
                ),
                loots,
                "</svg>"
            );
    }

}
