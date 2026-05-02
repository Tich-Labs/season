const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Montserrat'],
      },
      colors: {
        brand: {
          primary: '#933a35',
          secondary: '#6B6B6B',
          background: '#FAF7F4',
          white: '#FFFFFF',
          field: '#EDE1D5',
          error: '#FDF0EE',
          muted: '#D18D83',
          divider: '#DDD0CB',
          dark: '#3d2b28',
        },
        phase: {
          menstrual: '#933a35',
          follicular: '#D18D83',
          ovulation: '#F5C6AD',
          luteal: '#EDE1D5',
        }
      },
      maxWidth: {
        'app': '430px',
      },
      gridAutoRows: {
        'calendar': '85px',
      },
      spacing: {
        '2.25': '0.5625rem',  // 9px
        '4.5': '1.125rem',    // 18px
      },
      minWidth: {
        '20': '5rem',  // 80px
      },
      lineHeight: {
        '11': '2.75rem',  // 44px (same as w-11)
      }
    },
  },
  plugins: [
  ]
}
