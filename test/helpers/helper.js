class Helper {
  // eslint-disable-next-line class-methods-use-this
  createCell(val, length) {
    let txt = `| ${String(val).trim()}`;

    while (txt.length < length) {
      txt += ' ';
    }
    txt += ' |';
    return txt;
  }

  createRow(array, length = 9) {
    let row = '';
    array.forEach((item, key) => {
      row += this.createCell(item, length);
      if (key !== array.length - 1) {
        row = row.slice(0, -1);
      }
    });

    return row;
  }
}

module.exports = Helper;
