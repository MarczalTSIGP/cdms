// $(document).ready(() => {
//   let oldTitle = '';
//   $('#print-button').on('click', () => {
//     let { title } = document;
//     oldTitle = title;
//     title = title
//       .replace(/\s/g, '_')
//       .replace(/[^a-zA-Zs-]/g, '')
//       .substring(0, 20);

//     document.title = title;
//     window.print();
//   });

//   window.onafterprint = () => {
//     document.title = oldTitle;
//   };
// });
